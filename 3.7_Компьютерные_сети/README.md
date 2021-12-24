# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

**1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?**

	ip a

>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000  
>...  
>2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000  
>...  

	ip link

>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000  
>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00  
>2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000  
>    link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff  

	ifconfig

>eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500  
>...  
>lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536  
>...  

	netstat -i

>Kernel Interface table  
>Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg  
>eth0      1500    43892      0      0 0         24009      0      0      0 BMRU  
>lo       65536      356      0      0 0           356      0      0      0 LRU  

**2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?**

	sudo apt install lldpd

	lldpctl

>-------------------------------------------------------------------------------  
>LLDP neighbors:  
>-------------------------------------------------------------------------------  
>Interface:    eth1, via: LLDP, RID: 1, Time: 0 day, 00:00:46  
>  Chassis:       
>    ChassisID:    mac 52:54:00:28:6e:26  
>    SysName:      vagrant-vbox  
>    SysDescr:     Debian GNU/Linux 11 (bullseye) Linux 5.10.0-9-amd64 #1 SMP Debian 5.10.70-1 (2021-09-30) x86_64  
>    MgmtIP:       192.168.1.5  
>    MgmtIP:       fe80::5054:ff:fe28:6e26  
>    Capability:   Bridge, off  
>    Capability:   Router, off  
>    Capability:   Wlan, off  
>    Capability:   Station, on  
>  Port:          
>    PortID:       mac 52:54:00:28:6e:26  
>    PortDescr:    enp1s0  
>    TTL:          120  

**3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.**

```
sudo apt install vlan

echo '
auto eth0.100
iface eth0.100 inet static
        address 172.16.0.100/24
        vlan_raw_device eth0
' | tee -a /etc/network/interfaces

sudo systemctl restart networking.service
ip a show eth0.100 
```

>4: eth0.100@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000  
>    link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff  
>    inet 172.16.0.100/24 brd 172.16.0.255 scope global eth0.100  
>       valid_lft forever preferred_lft forever  
>    inet6 fe80::a00:27ff:fe73:60cf/64 scope link   
>       valid_lft forever preferred_lft forever  


**4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.**

	sudo apt install ifenslave

```
auto eth0
iface eth0 inet manual
        bond-master bond0

auto eth1
iface eth1 inet manual
        bond-master bond0

auto bond0
iface bond0 inet dhcp
        bond-mode 1
        bond-miimon 100
        bond-primary eth0 eth1
```
---

**mode** Specifies one of the bonding policies. The default is balance-rr (round robin). Possible values are:

***balance-rr*** - Round-robin policy: Transmit packets in sequential order from the first available slave through the last. This mode provides load balancing and fault tolerance.

***active-backup*** - Active-backup policy: Only one slave in the bond is active.

***balance-xor*** - XOR policy: Transmit based on the selected transmit hash policy.

***broadcast*** - Broadcast policy: transmits everything on all slave interfaces. This mode provides fault tolerance.

***802.3ad*** - IEEE 802.3ad Dynamic link aggregation. Creates aggregation groups that share the same speed and duplex settings. Utilizes all slaves in the active aggregator according to the 802.3ad specification.

***balance-tlb*** - Adaptive transmit load balancing: channel bonding that does not require any special switch support. The outgoing traffic is distributed according to the current load (computed relative to the speed) on each slave. Incoming traffic is received by the current slave. If the receiving slave fails, another slave takes over the MAC address of the failed receiving slave.

***balance-alb*** - Adaptive load balancing: includes balance-tlb plus receive load balancing (rlb) for IPV4 traffic, and does not require any special switch support. The receive load balancing is achieved by ARP negotiation.

**5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.**

	sipcalc 10.0.0.0/29

>-[ipv4 : 10.0.0.0/29] - 0  
>  
>[CIDR]  
>Host address		- 10.0.0.0  
>Host address (decimal)	- 167772160  
>Host address (hex)	- A000000  
>Network address		- 10.0.0.0  
>Network mask		- 255.255.255.248  
>Network mask (bits)	- 29  
>Network mask (hex)	- FFFFFFF8  
>Broadcast address	- 10.0.0.7  
>Cisco wildcard		- 0.0.0.7  
>**Addresses in network	- 8**  
>Network range		- 10.0.0.0 - 10.0.0.7  
>Usable range		- 10.0.0.1 - 10.0.0.6  

	sipcalc 10.10.10.0/24 -s 29

>-[ipv4 : 10.10.10.0/24] - 0  
>  
>[Split network]  
>Network			- 10.10.10.0      - 10.10.10.7  
>Network			- 10.10.10.8      - 10.10.10.15  
>Network			- 10.10.10.16     - 10.10.10.23  
>Network			- 10.10.10.24     - 10.10.10.31  
>Network			- 10.10.10.32     - 10.10.10.39  
>Network			- 10.10.10.40     - 10.10.10.47  
>Network			- 10.10.10.48     - 10.10.10.55  
>Network			- 10.10.10.56     - 10.10.10.63  
>Network			- 10.10.10.64     - 10.10.10.71  
>Network			- 10.10.10.72     - 10.10.10.79  
>Network			- 10.10.10.80     - 10.10.10.87  
>Network			- 10.10.10.88     - 10.10.10.95  
>Network			- 10.10.10.96     - 10.10.10.103  
>Network			- 10.10.10.104    - 10.10.10.111  
>Network			- 10.10.10.112    - 10.10.10.119  
>Network			- 10.10.10.120    - 10.10.10.127  
>Network			- 10.10.10.128    - 10.10.10.135  
>Network			- 10.10.10.136    - 10.10.10.143  
>Network			- 10.10.10.144    - 10.10.10.151  
>Network			- 10.10.10.152    - 10.10.10.159  
>Network			- 10.10.10.160    - 10.10.10.167  
>Network			- 10.10.10.168    - 10.10.10.175  
>Network			- 10.10.10.176    - 10.10.10.183  
>Network			- 10.10.10.184    - 10.10.10.191  
>Network			- 10.10.10.192    - 10.10.10.199  
>Network			- 10.10.10.200    - 10.10.10.207  
>Network			- 10.10.10.208    - 10.10.10.215  
>Network			- 10.10.10.216    - 10.10.10.223  
>Network			- 10.10.10.224    - 10.10.10.231  
>Network			- 10.10.10.232    - 10.10.10.239  
>Network			- 10.10.10.240    - 10.10.10.247  
>Network			- 10.10.10.248    - 10.10.10.255  

**6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.**

[100.64.0.0/10 - IPv4 shared address space](https://en.wikipedia.org/wiki/IPv4_shared_address_space)

	ipcalc 100.64.0.0/10 -b -s 50

>Address:   100.64.0.0             
>Netmask:   255.192.0.0 = 10       
>Wildcard:  0.63.255.255           
>
>Network:   100.64.0.0/10          
>HostMin:   100.64.0.1             
>HostMax:   100.127.255.254        
>Broadcast: 100.127.255.255        
>Hosts/Net: 4194302               Class A  
>  
>1. Requested size: 50 hosts  
>Netmask:   255.255.255.192 = 26   
>**Network:   100.64.0.0/26**          
>HostMin:   100.64.0.1             
>HostMax:   100.64.0.62            
>Broadcast: 100.64.0.63            
>Hosts/Net: 62                    Class A  
>  
>Needed size:  64 addresses.  
>Used network: 100.64.0.0/26  
>Unused:  
>100.64.0.64/26  
>100.64.0.128/25  
>100.64.1.0/24  
>100.64.2.0/23  
>100.64.4.0/22  
>100.64.8.0/21  
>100.64.16.0/20  
>100.64.32.0/19  
>100.64.64.0/18  
>100.64.128.0/17  
>100.65.0.0/16  
>100.66.0.0/15  
>100.68.0.0/14  
>100.72.0.0/13  
>100.80.0.0/12  
>100.96.0.0/11  

**7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?**

	arp

>Address                  HWtype  HWaddress           Flags Mask            Iface  
>10.0.2.2                 ether   52:54:00:12:35:02   C                     eth0  
>10.0.2.3                 ether   52:54:00:12:35:03   C                     eth0  

	sudo arp -d 10.0.2.2

	sudo ip -s -s neigh flush all

>10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 ref 1 used 36/0/32 probes 1 REACHABLE  
>10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 ref 1 used 36/32/32 probes 1 REACHABLE  
>  
>Round 1, deleting 2 entries  
>Flush is complete after 1 round  
