# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

**1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`.**

	strace /bin/bash -c 'cd /tmp && exit'

>...  
>stat("/tmp", {st_mode=S_IFDIR|S_ISVTX|0777, st_size=4096, ...}) = 0  
>**chdir("/tmp")                           = 0**  
>rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0  
>rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0  
>exit_group(0)                           = ?  
>+++ exited with 0 +++  

**2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:**

```
vagrant@netology1:~$ file /dev/tty
/dev/tty: character special (5/0)
vagrant@netology1:~$ file /dev/sda
/dev/sda: block special (8/0)
vagrant@netology1:~$ file /bin/bash
/bin/bash: ELF 64-bit LSB shared object, x86-64
```

Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.

	strace -e trace=openat file /dev/tty

>...  
>openat(AT_FDCWD, "**/etc/magic.mgc**", O_RDONLY) = -1 ENOENT (No such file or directory)  
>openat(AT_FDCWD, "**/etc/magic**", O_RDONLY) = 3  
>openat(AT_FDCWD, "**/usr/share/misc/magic.mgc**", O_RDONLY) = 3  
>/dev/tty: character special (5/0)  
>+++ exited with 0 +++  


**3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (`deleted` в `lsof`), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).**

	terminal_1:
	echo 123 > test_file
	vim test_file
	
	terminal_2:
	lsof -p $(pidof vim) | grep home

>vim     5521 vagrant  cwd    DIR  253,0     4096 131074 /home/vagrant  
>vim     5521 vagrant    4u   REG  253,0    12288 131086 **/home/vagrant/.test_file.swp**  

	cat .test_file.swp 

>3210#"! Utpad 321123 fileutf-8

	rm .test_file.swp 
	lsof -p $(pidof vim) | grep home

>vim     5521 vagrant  cwd    DIR  253,0     4096 131074 /home/vagrant  
>vim     5521 vagrant    **4**u   REG  253,0    12288 131086 /home/vagrant/.test_file.swp **(deleted)**  

	cat /proc/$(pidof vim)/fd/4 > .test_file.swp
	cat .test_file.swp

>3210#"! Utpad 321123 fileutf-8

Процессом `vim` был создан временный файл `.test_file.swp`, в котором хранятся несохраненные данные об изменениях оригинального файла, а так же файловый дескриптор `4` к нему. Информация удаленного файла может быть извлечена из данного файлового дескриптора. Для обнуления можно выполнить команду:

	echo > /proc/$(pidof vim)/fd/5
	cat /proc/$(pidof vim)/fd/5

>` `

**4. Занимают ли зомби-процессы какие-то ресурсы в ОС (`CPU`, `RAM`, `IO`)?**

Зомби-процессы не используют системные ресурсы, за исключением тех, которые свидетельствую о их существовании.

	$(sleep 1 & exec /bin/sleep 10)

	ps axo stat,ppid,pid,comm | grep Z

>Z+      6513    **6514** sleep <defunct>

	ls /proc/6514/

>arch_status      environ    mountinfo      personality   statm  
>attr             exe        mounts         projid_map    status  
>autogroup        fd         mountstats     root          syscall  
>auxv             fdinfo     net            sched         task  
>cgroup           gid_map    ns             schedstat     timers  
>clear_refs       io         numa_maps      sessionid     timerslack_ns  
>cmdline          limits     oom_adj        setgroups     uid_map  
>comm             loginuid   oom_score      smaps         wchan  
>coredump_filter  map_files  oom_score_adj  smaps_rollup  
>cpuset           maps       pagemap        stack  
>cwd              mem        patch_state    stat  

Информация о зомби-процессе хранится в системе, используя при это минимальное количество ресурсов песевдо-файловой системы `proc` (оперативной памяти), а так же процессора для манипуляций с данным процессом.

**5. В `iovisor BCC` есть утилита `opensnoop`. На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для `Ubuntu 20.04`.**

```
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
```

	sudo opensnoop-bpfcc 

>PID    COMM               FD ERR PATH  
>584    irqbalance          6   0 /proc/interrupts  
>584    irqbalance          6   0 /proc/stat  
>584    irqbalance          6   0 /proc/irq/20/smp_affinity  
>584    irqbalance          6   0 /proc/irq/0/smp_affinity  
>584    irqbalance          6   0 /proc/irq/1/smp_affinity  
>584    irqbalance          6   0 /proc/irq/8/smp_affinity  
>584    irqbalance          6   0 /proc/irq/12/smp_affinity  
>584    irqbalance          6   0 /proc/irq/14/smp_affinity  
>584    irqbalance          6   0 /proc/irq/15/smp_affinity  
>774    vminfo              4   0 /var/run/utmp  
>580    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services  
>580    dbus-daemon        18   0 /usr/share/dbus-1/system-services  
>580    dbus-daemon        -1   2 /lib/dbus-1/system-services  
>580    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/  


**6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.**

	strace uname -a

>**uname({sysname="Linux", nodename="vagrant", ...}) = 0**  
>fstat(1, {st_mode=S_IFCHR|0620, st_rdev=makedev(0x88, 0), ...}) = 0  
>**uname({sysname="Linux", nodename="vagrant", ...}) = 0**  
>**uname({sysname="Linux", nodename="vagrant", ...}) = 0**  
>write(1, "Linux vagrant 5.4.0-80-generic #"..., 105Linux vagrant 5.4.0-80-generic #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux) = 105  
>close(1)                                = 0  
>close(2)                                = 0  
>exit_group(0)                           = ?  
>+++ exited with 0 +++  

	man 2 uname

```
Manual page uname(2) line 66

       Part of the utsname information is also accessible  via  /proc/sys/ker‐
       nel/{ostype, hostname, osrelease, version, domainname}.
```

	cat /proc/version

>Linux version 5.4.0-80-generic (buildd@lcy01-amd64-030) (gcc version 9.3.0 (Ubuntu 9.3.0-17ubuntu1~20.04)) #90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021

	cat /proc/sys/kernel/ostype 

>Linux

	cat /proc/sys/kernel/hostname 

>vagrant

	cat /proc/sys/kernel/osrelease 

>5.4.0-80-generic

	cat /proc/sys/kernel/version 

>90-Ubuntu SMP Fri Jul 9 22:49:44 UTC 2021


**7. Чем отличается последовательность команд через ; и через `&&` в `bash`? Например:**
```
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
```
`;` - последовательно выполняет команды, вне зависимости от результата
`&&` - условие `AND`, вторая команда будет выполнена, если первая закончилась успешно

Есть ли смысл использовать в bash &&, если применить set -e?

```
 Manual page bash(1) line 3293
 
               -e      Exit  immediately if a pipeline (which may consist of a single simple command), a list, or a compound command (see SHELL GRAMMAR above),
                      exits with a non-zero status.  The shell does not exit if the command that fails is part of the command  list  immediately  following  a
                      while or until keyword, part of the test following the if or elif reserved words, part of any command executed in a && or || list except
                      the command following the final && or ||, any command in a pipeline but the last, or if the command's return  value  is  being  inverted
                      with  !.  If a compound command other than a subshell returns a non-zero status because a command failed while -e was being ignored, the
                      shell does not exit.  A trap on ERR, if set, is executed before the shell exits.  This option applies to the shell environment and  each
                      subshell environment separately (see COMMAND EXECUTION ENVIRONMENT above), and may cause subshells to exit before executing all the com‐
                      mands in the subshell.
```

Меняется подход к выходу из pipeline, при этом можно использовать при других сценариях. 

**8. Из каких опций состоит режим `bash set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?**

```
 Manual page bash(1) line 3282
 
       set [--abefhkmnptuvxBCEHPT] [-o option-name] [arg ...]
       set [+abefhkmnptuvxBCEHPT] [+o option-name] [arg ...]
...

              -u      Treat  unset variables and parameters other than the special parameters "@" and "*" as an error when performing parameter expansion.  If
                      expansion is attempted on an unset variable or parameter, the shell prints an error message, and, if not interactive, exits with a  non-
                      zero status.
                      
              -x      After expanding each simple command, for command, case command, select command, or arithmetic for command, display the expanded value of
                      PS4, followed by the command and its expanded arguments or associated word list.
                      
              -o option-name
                      The option-name can be one of the following:
                      ...
                      pipefail
                              If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or  zero  if
                              all commands in the pipeline exit successfully.  This option is disabled by default.
```

**9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать `S`, `Ss` или `Ssl` равнозначными).**

```
 Manual page ps(1) line 389
 
 PROCESS STATE CODES
       Here are the different values that the s, stat and state output specifiers (header "STAT" or "S") will display to describe the state of a process:

               D    uninterruptible sleep (usually IO)
               I    Idle kernel thread
               R    running or runnable (on run queue)
               S    interruptible sleep (waiting for an event to complete)
               T    stopped by job control signal
               t    stopped by debugger during the tracing
               W    paging (not valid since the 2.6.xx kernel)
               X    dead (should never be seen)
               Z    defunct ("zombie") process, terminated but not reaped by its parent

       For BSD formats and when the stat keyword is used, additional characters may be displayed:

               <    high-priority (not nice to other users)
               N    low-priority (nice to other users)
               L    has pages locked into memory (for real-time and custom IO)
               s    is a session leader
               l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
               +    is in the foreground process group
```

	sudo ps ax -o stat= | sort | uniq -c -w 1

>**49 I**  
>**1 R+**  
>**51 S**  
