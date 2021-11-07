# Домашнее задание к занятию «2.1. Системы контроля версий.»
## Задание №1 – Создать и настроить репозиторий для дальнейшей работы на курсе.
### Создайте репозиторий и первый коммит:

	git clone https://github.com/badanin/devops-netology 
	git config --global user.name 'Badanin Maksim'
	git config --global user.email 'e@ma.il
	git add origin git@github.com:badanin/devops-netology

	git status

>On branch master  
nothing to commit, working tree clean

	echo 'add new line' >> README.md 
	git status

>On branch master  
>Changes not staged for commit:  
>	modified:   README.md  
>  
>no changes added to commit (use "git add" and/or "git commit -a")

	git diff

>diff --git a/README.md b/README.md  
>index fa082c6..1dc1b95 100644  
>--- a/README.md  
>+++ b/README.md  
>@@ -1 +1,2 @@  
> devops-netology  
>+add new line

	git diff --staged
>  -

	git add README.md
	git status

>On branch master  
>Changes to be committed:  
>	modified:   README.md

	git diff
> -

	git diff --staged

>diff --git a/README.md b/README.md  
>index fa082c6..1dc1b95 100644  
>--- a/README.md  
>+++ b/README.md  
>@@ -1 +1,2 @@  
> devops-netology  
>+add new line

	git commit -m 'First commit'

>[master 870fd5d] First commit  
> 1 file changed, 1 insertion(+)

	git diff
> -

	git diff --staged
> -

### Создадим файлы .gitignore и второй коммит:

	touch .gitignore
	git add .gitignore
	mkdir terraform

	echo '**/.terraform/*
	*.tfstate
	*.tfstate.*
	crash.log
	*.tfvars
	override.tf
	override.tf.json
	*_override.tf
	*_override.tf.json
	.terraformrc
	terraform.rc'  > terraform/.gitignore

Будут проигнорированы:
- все содержимое каталога *.terraform*;
- файлы с расширением: *tfstate, tfvars, _override.tf, _override.tf.json*; 
- файлы: *crash.log, override.tf, override.tf.json, .terraformrc, terraform.rc*
.

	git add *
	git commit -m 'Added gitignore'

>[master ee41bd2] Added gitignore  
> 2 file changed, 0 insertions(+), 0 deletions(-)  
> create mode 100644 .gitignore  
> create mode 100644 terraform/.gitignore

### Экспериментируем с удалением и перемещением файлов (третий и четвертый коммит).

	echo 'will_be_deleted' > will_be_deleted.txt
	echo 'will_be_moved' > will_be_moved.txt
	git add .
	git commit -m 'Prepare to delete and move'

>[master cfdbc5a] Prepare to delete and move  
> 2 files changed, 2 insertions(+)  
> create mode 100644 will_be_deleted.txt  
> create mode 100644 will_be_moved.txt

	rm will_be_deleted.txt 
	mv will_be_moved.txt has_been_moved.txt
	git add .
	git commit -m 'Moved and deleted'

>[master e99ec60] Moved and deleted  
> 2 files changed, 1 deletion(-)  
> rename will_be_moved.txt => has_been_moved.txt (100%)  
> delete mode 100644 will_be_deleted.txt


### Проверка изменений.

	git log

>commit e99ec60cf775cd55cbb0d481c4509e7c79cb5050 (HEAD -> master)  
>Author: Badanin Maksim <e@ma.il>  
>Date:   Sat Oct 30 13:38:42 2021 +0300  
>  
>    Moved and deleted  
>  
>commit cfdbc5a0d7ca22facfd3ec1a6ce8f5842f518555  
>Author: Badanin Maksim <e@ma.il>  
>Date:   Sat Oct 30 13:31:29 2021 +0300  
>  
>    Prepare to delete and move  
>  
>commit ee41bd2208548363c60a5382273a6959e4f47513  
>Author: Badanin Maksim <e@ma.il>  
>Date:   Sat Oct 30 13:20:01 2021 +0300  
>  
>    Added gitignore  
>  
>commit 870fd5d66853e12201cdb9b65cc6c1c19b4d37ef  
>Author: Badanin Maksim <e@ma.il>  
>Date:   Sat Oct 30 09:57:21 2021 +0300  
>  
>    First commit  
>  
>commit 456f71b8996928319187b374ad6eb65685fe5d3b  
>Author: Badanin Maksim <e@ma.il>  
>Date:   Sat Oct 30 09:28:57 2021 +0300  
>  
>    Initial commit

### Отправка изменений в репозиторий.

	git push -u origin master

>Enumerating objects: 19, done.  
>Counting objects: 100% (19/19), done.  
>Delta compression using up to 12 threads  
>Compressing objects: 100% (11/11), done.  
>Writing objects: 100% (19/19), 1.50 KiB | 1.50 MiB/s, done.  
>Total 19 (delta 3), reused 0 (delta 0), pack-reused 0  
>remote: Resolving deltas: 100% (3/3), done.  
>To github.com:badanin/devops-netology  
> * [new branch]      master -> master  
>Branch 'master' set up to track remote branch 'master' from 'origin'.

## Задание №2 – Знакомство с документаций

	git --help
	git add --help