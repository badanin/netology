#!/usr/bin/env bash
export VAULT_ADDR=http://127.0.0.1:8200

vault operator unseal $(cat /etc/vault.d/unseal1.key)
vault login $(cat /etc/vault.d/initial.token)

vault write pki_int/roles/example-dot-com allowed_domains="example.com" allow_subdomains=true max_ttl="720h"
vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="720h" > test.example.com.crt

cat test.example.com.crt | jq -r .data.certificate | sudo tee /etc/certs/test.example.com.crt.pem
cat test.example.com.crt | jq -r .data.issuing_ca | sudo tee -a /etc/certs/test.example.com.crt.pem
cat test.example.com.crt | jq -r .data.private_key | sudo tee /etc/certs/test.example.com.crt.key

systemctl restart nginx.service
