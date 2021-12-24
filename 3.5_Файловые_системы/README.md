# Домашнее задание к занятию "3.5. Файловые системы"

**1. Узнайте о sparse (разряженных) файлах.**

>Разрежённый файл (англ. sparse file) — файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях (список дыр).  

*Преимущества:*

- экономия дискового пространства. Использование разрежённых файлов считается одним из способов сжатия данных на уровне файловой системы;
- отсутствие временных затрат на запись нулевых байт;
- увеличение срока службы запоминающих устройств.

*Недостатки:*

- накладные расходы на работу со списком дыр;
- фрагментация файла при частой записи данных в дыры;
- невозможность записи данных в дыры при отсутствии свободного места на диске;
- невозможность использования других индикаторов дыр, кроме нулевых байт.

**2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?**

Не могут.

	touch test_file
	stat test_file 

>File: **test_file**  
>Size: 0         	Blocks: 0          IO Block: 4096   regular empty file  
>Device: fd00h/64768d	Inode: 131081      Links: 1  
>**Access: (0664/-rw-rw-r--)  Uid: ( 1000/ vagrant)   Gid: ( 1000/ vagrant)**  
>Access: 2021-12-24 07:12:03.119033676 +0000  
>Modify: 2021-12-24 07:12:03.119033676 +0000  
>Change: 2021-12-24 07:12:03.119033676 +0000  
>Birth:  

	ln test_file test_symlink
	sudo chown root:root test_symlink
	stat test_file

>File: **test_file**  
>Size: 0         	Blocks: 0          IO Block: 4096   regular empty file  
>Device: fd00h/64768d	Inode: 131081      Links: 2  
>**Access: (0664/-rw-rw-r--)  Uid: (    0/    root)   Gid: (    0/    root)**  
>Access: 2021-12-24 07:12:03.119033676 +0000  
>Modify: 2021-12-24 07:12:03.119033676 +0000  
>Change: 2021-12-24 07:15:01.208033680 +0000  
>Birth:  


**3. Сделайте vagrant destroy на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:**

Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

```
echo 'Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider :virtualbox do |vb|
    lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
    lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
    vb.customize ["createmedium", "--filename", lvm_experiments_disk0_path, "--size", 2560]
    vb.customize ["createmedium", "--filename", lvm_experiments_disk1_path, "--size", 2560]
    vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 1, "--device", 0, "--type", "hdd", "--medium", lvm_experiments_disk0_path]
    vb.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 2, "--device", 0, "--type", "hdd", "--medium", lvm_experiments_disk1_path]
  end
end' > Vagrantfile
```

	vagrant up

**4. Используя fdisk, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.**

	lsblk

>NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT  
>...  
>sdb                    8:16   0  2.5G  0 disk   
>sdc                    8:32   0  2.5G  0 disk   

```
sudo fdisk /dev/sdb

g
n
1
2048
+2G
n
2
4196352
5242846
wq
```

	lsblk

>NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT  
>...  
>sdb                    8:16   0  2.5G  0 disk   
>**├─sdb1                 8:17   0    2G  0 part**  
>**└─sdb2                 8:18   0  511M  0 part**  
>sdc                    8:32   0  2.5G  0 disk   

**5. Используя sfdisk, перенесите данную таблицу разделов на второй диск.**

	sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc

>Checking that no-one is using this disk right now ... OK  
>  
>Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors  
>Disk model: VBOX HARDDISK     
>Units: sectors of 1 * 512 = 512 bytes  
>Sector size (logical/physical): 512 bytes / 512 bytes  
>I/O size (minimum/optimal): 512 bytes / 512 bytes  
>  
>Script header accepted.  
>Script header accepted.  
>Script header accepted.  
>Script header accepted.  
>Script header accepted.  
>Script header accepted.  
>Created a new GPT disklabel (GUID: 7CDE72BE-31CF-E149-9EF9-4C73DDFE9DEF).  
>/dev/sdc1: Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.  
>/dev/sdc2: Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.  
>/dev/sdc3: Done.  
>  
>New situation:  
>Disklabel type: gpt  
>Disk identifier: 7CDE72BE-31CF-E149-9EF9-4C73DDFE9DEF  
>  
>Device       Start     End Sectors  Size Type  
>/dev/sdc1     2048 4196351 4194304    2G Linux filesystem  
>/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem  
>  
>The partition table has been altered.  
>Calling ioctl() to re-read partition table.  
>Syncing disks.  

	lsblk

>NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT  
>...  
>sdb                    8:16   0  2.5G  0 disk   
>├─sdb1                 8:17   0    2G  0 part  
>└─sdb2                 8:18   0  511M  0 part  
>sdc                    8:32   0  2.5G  0 disk   
>**├─sdc1                 8:33   0    2G  0 part**  
>**└─sdc2                 8:34   0  511M  0 part**  

**6. Соберите mdadm RAID1 на паре разделов 2 Гб.**

	yes | sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b1,c1}

>mdadm: Note: this array has metadata at the start and  
>may not be suitable as a boot device.  If you plan to  
>store '/boot' on this device please ensure that  
>your boot-loader understands md/v1.x metadata, or use  
>--metadata=0.90  
>mdadm: size set to 2094080K  
>Continue creating array? mdadm: Defaulting to version 1.2 metadata  
>mdadm: array /dev/md0 started.  

	lsblk

>NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT  
>...  
>sdb                    8:16   0  2.5G  0 disk    
>├─sdb1                 8:17   0    2G  0 part    
>**│ └─md0                9:0    0    2G  0 raid1**  
>└─sdb2                 8:18   0  511M  0 part    
>sdc                    8:32   0  2.5G  0 disk    
>├─sdc1                 8:33   0    2G  0 part    
>**│ └─md0                9:0    0    2G  0 raid1**  
>└─sdc2                 8:34   0  511M  0 part    

**7. Соберите mdadm RAID0 на второй паре маленьких разделов.**

	yes | sudo mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sd{b2,c2}

>mdadm: chunk size defaults to 512K  
>mdadm: Defaulting to version 1.2 metadata  
>mdadm: array /dev/md1 started.  

	lsblk

>NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT  
>...  
>sdb                    8:16   0  2.5G  0 disk    
>├─sdb1                 8:17   0    2G  0 part    
>│ └─md0                9:0    0    2G  0 raid1   
>└─sdb2                 8:18   0  511M  0 part    
>**..└─md1                9:1    0 1017M  0 raid0**  
>sdc                    8:32   0  2.5G  0 disk    
>├─sdc1                 8:33   0    2G  0 part    
>│ └─md0                9:0    0    2G  0 raid1   
>└─sdc2                 8:34   0  511M  0 part    
>**..└─md1                9:1    0 1017M  0 raid0**  

**8. Создайте 2 независимых PV на получившихся md-устройствах.**

	sudo pvcreate /dev/md{0,1}

>Physical volume "/dev/md0" successfully created.  
>Physical volume "/dev/md1" successfully created.  

	sudo pvs

>PV         VG        Fmt  Attr PSize    PFree     
>/dev/md0             lvm2 ---    <2.00g   <2.00g  
>/dev/md1             lvm2 ---  1017.00m 1017.00m  

**9. Создайте общую volume-group на этих двух PV.**

	sudo vgcreate vg0 /dev/md0 /dev/md1
	
>Volume group "vg0" successfully created  

	sudo vgs

>VG        #PV #LV #SN Attr   VSize   VFree   
>vg0         2   0   0 wz--n-  <2.99g <2.99g  

**10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.**

	sudo lvcreate -L 100M -n lv0 vg0 /dev/md1

>Logical volume "lv0" created.  

	sudo lvs -o +devices

>LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices           
>lv0    vg0       -wi-a----- 100.00m                                                     /dev/md1(0)  

**11. Создайте mkfs.ext4 ФС на получившемся LV.**

	sudo mkfs.ext4 /dev/vg0/lv0 

>mke2fs 1.45.5 (07-Jan-2020)  
>Creating filesystem with 25600 4k blocks and 25600 inodes  
>  
>Allocating group tables: done                              
>Writing inode tables: done                              
>Creating journal (1024 blocks): done  
>Writing superblocks and filesystem accounting information: done  

**12. Смонтируйте этот раздел в любую директорию, например, /tmp/new.**

	sudo mkdir /tmp/new
	sudo mount /dev/vg0/lv0 /tmp/new/

**13. Поместите туда тестовый файл, например wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz.**

	sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz

>--2021-12-24 06:34:21--  https://mirror.yandex.ru/ubuntu/ls-lR.gz  
>Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183  
>Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.  
>HTTP request sent, awaiting response... 200 OK  
>Length: 21520128 (21M) [application/octet-stream]  
>Saving to: ‘/tmp/new/test.gz’  
>  
>/tmp/new/test.gz            100%[========================================>]  20.52M  38.7MB/s    in 0.5s      
>  
>2021-12-24 06:34:22 (38.7 MB/s) - ‘/tmp/new/test.gz’ saved [21520128/21520128]  

**14. Прикрепите вывод lsblk.**

	lsblk

>NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT  
>...  
>sdb                    8:16   0  2.5G  0 disk    
>├─sdb1                 8:17   0    2G  0 part    
>│ └─md0                9:0    0    2G  0 raid1   
>└─sdb2                 8:18   0  511M  0 part    
>..└─md1                9:1    0 1017M  0 raid0   
>....└─vg0-lv0        253:2    0  100M  0 lvm   /tmp/new  
>sdc                    8:32   0  2.5G  0 disk    
>├─sdc1                 8:33   0    2G  0 part    
>│ └─md0                9:0    0    2G  0 raid1   
>└─sdc2                 8:34   0  511M  0 part    
>..└─md1                9:1    0 1017M  0 raid0   
>....└─vg0-lv0        253:2    0  100M  0 lvm   /tmp/new  

**15. Протестируйте целостность файла:**

	gzip -t /tmp/new/test.gz
	echo $?

>0  

**16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.**

	sudo pvmove /dev/md1 /dev/md0

>/dev/md1: Moved: 100.00%  

**17. Сделайте --fail на устройство в вашем RAID1 md.**

	sudo mdadm /dev/md0 -f /dev/sdc1

>mdadm: set /dev/sdc1 faulty in /dev/md0  

**18. Подтвердите выводом dmesg, что RAID1 работает в деградированном состоянии.**

	sudo dmesg | tail

>...  
>[ 3861.607777] md/raid1:md0: Disk failure on sdc1, disabling device.  
>md/raid1:md0: Operation continuing on 1 devices.  


**19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:**

	gzip -t /tmp/new/test.gz
	echo $?

>0  

**20. Погасите тестовый хост, vagrant destroy.**

	vagrant halt 
	vagrant destroy 
