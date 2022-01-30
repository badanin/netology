#!/usr/bin/env bash

# ==========
# Обновляем систему и устанавливаем ufw
apt update
#apt dist-upgrade -y
apt install -y bash-completion ufw socat

ufw default deny incoming
ufw default allow outgoing
ufw allow http
ufw allow https
ufw allow from 127.0.0.0/8
#yes | ufw enable 

# ==========
# Устанавливаем Vault
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update 
apt-get install -y vault jq
vault -autocomplete-install

sed -e '/#listener/,+4 s/#//' /etc/vault.d/vault.hcl | sed -e '/# HTTPS/,+5 s/^/#/' | tee /etc/vault.d/vault.hcl

systemctl enable vault.service
systemctl start vault.service

sleep 2

# Инициализация Vault
export VAULT_ADDR=http://127.0.0.1:8200
mkdir /etc/certs

vault operator init -n 1 -t 1 | tee /etc/vault.d/init.file

cat /etc/vault.d/init.file | grep "Unseal Key 1: " | sed 's/Unseal Key 1: //' | tee /etc/vault.d/unseal1.key
cat /etc/vault.d/init.file | grep "Initial Root Token: " | sed 's/Initial Root Token: //' | tee /etc/vault.d/initial.token

socat STDIO 'EXEC:vault operator unseal,PTY' <<< $(cat /etc/vault.d/unseal1.key)
socat STDIO 'EXEC:vault login,PTY' <<< $(cat /etc/vault.d/initial.token)

# Генерация корневого CA
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal common_name="example.com" ttl=87600h | tee /vagrant/CA_cert.crt /etc/certs/CA_cert.crt
vault write pki/config/urls issuing_certificates="$VAULT_ADDR/v1/pki/ca" crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

# Генерация промежуточного CA
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int
vault write -format=json pki_int/intermediate/generate/internal common_name="example.com Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr
vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > intermediate.cert.pem
vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem

# Генерация сертификатов домена
vault write pki_int/roles/example-dot-com allowed_domains="example.com" allow_subdomains=true max_ttl="720h"
vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="720h" > test.example.com.crt

cat test.example.com.crt | jq -r .data.certificate | tee /etc/certs/test.example.com.crt.pem
cat test.example.com.crt | jq -r .data.issuing_ca | tee -a /etc/certs/test.example.com.crt.pem
cat test.example.com.crt | jq -r .data.private_key | tee /etc/certs/test.example.com.crt.key

# ==========
# Настройка NGINX
apt install -y nginx
echo 'server {
        listen                  443 ssl;
        server_name             test.example.com;
        ssl_certificate         /etc/certs/test.example.com.crt.pem;
        ssl_certificate_key     /etc/certs/test.example.com.crt.key;
        ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers             HIGH:!aNULL:!MD5;
}' | tee /etc/nginx/sites-enabled/test.example.com

systemctl restart nginx.service

# ==========
# Добавляем cron для обновления сертификата
cp /vagrant/regen.sh /etc/vault.d/regen.sh
chmod +x /etc/vault.d/regen.sh

echo '0 0 1 * * root /etc/vault.d/regen.sh' | sudo tee -a /etc/crontab
