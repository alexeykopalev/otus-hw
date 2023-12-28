#  Копалев А. С. - Домашняя работа № 3

## Задача
Развернуть InnoDB или PXC кластер
#### Цель
Перевести базу веб-проекта на один из вариантов кластера MySQL: Percona XtraDB Cluster или InnoDB Cluster.
#### Описание/Пошаговая инструкция выполнения домашнего задания:
Разворачиваем отказоустойчивый кластер MySQL (PXC || Innodb) на ВМ или в докере любым способом
Создаем внутри кластера вашу БД для проекта
#### Выполнение
Для развёртки инфраструктуры использовался Terraform и Ansible.
Через Terraform в Yandex Cloud создаются следующие ресурсы (через модули):
- Облачная сеть - network1
- 3 подсети - subnet-1, subnet-2, subnet-3 в разных зонах доступности для виртуальных машин бэкенда, серверов БД, сервера proxysql и сервера iscsi, subnet-bast, для бастионного хоста
- 1 виртуальная машина bast-host-srv с внешним IP-адресом, доступная по SSH, реализующая SSH доступ к остальным виртуалкам
- DNS зону - zone1, A-запись для домена dip-akopalev.ru
- 3 виртуальные машина для Percona XtraDB Cluster
- 1 виртуальная машина для ProxySQL в качестве балансировщика
- 3 виртуальные машины для бэкенда Wordpress
- 1 виртуальная машина с доп. диском для общего хранилища виртуальных машин backend
- 1 Yandex Application Load Balancer в качестве балансировщика

[main.tf](./main.tf)

Через Ansible реализуются 7 ролей:
 - "chrony" - установка и синхронизация времени на всех виртуальных машинах
 - "targetcli" - устанавливает targetcli, создает LUN, прописывает ACL клиентов (переменные зашифрованы через ansible-vault) для использования в качестве общей ФС gfs2 для бэкенд серверах, для хранения статики
 - "iscsi-client" - устанавливает iscsi-клиент, подключает LUN с сервера как блочное устройство 
 - "ha-cluster" - станавливает pacemaker, pcs, fence agent, lvm2, lvm2-lockd, dlm,gfs2-utils. Настраивает кластер, создает необходимые ресурсы, создает кластерную ФС.
 - "db" - устанавливает кластер MySQL: Percona XtraDB Cluster, задает пароль root, создает БД Wordpress, пользователей и пароли для подключения ProxySQL (переменные зашифрованы через ansible-vault)
 - "proxysql" - устанавливает ProxySQL для подключения к кластеру ДБ, задает пароль root, создает пользователей и пароли для подключния Wordpress (переменные зашифрованы через ansible-vault)
 - "wordpress" - устанавливает на бэкенд сервера nginx и каталог wordpress в директорию но общей ФС, заменяет их конфиги

[playbook.tf](./ansible/playbook.yml)

## Скриншоты из Yandex Cloud, созданного сайта, выводы при выполнении terraform apply и ansible-playbook playbook.yml

- созданные виртуальные машины
  
![](files/pic/1.png)

- группы безопасности
  
![](files/pic/2.png)

- созданные подсети
  
![](files/pic/3.png)

- Балансировщик Yandex Application Load Balancer
  
![](files/pic/4.png)

- Заканчиваем установку Wordpress
  
![](files/pic/5.png)

- Работа админки сайта

![](files/pic/6.png)

- Работа сайта

![](files/pic/7.png)

- Проверяем сосояние кластера MySQL через ProxySQL

![](files/pic/8.png)

- Выключение виртуалки MySQL - db-srv2 

![](files/pic/9.png)

- Сосояние кластера MySQL через ProxySQL

![](files/pic/10.png)

- Добавляем новую запись в БД

![](files/pic/11.png)

- Проверяем записи в таблице на другой виртуалке MySQL

![](files/pic/12.png)

- Запускаем выключенную виртуалку проверяем состояние через ProxySQL

![](files/pic/13.png)

- Выключение виртуалоки MySQL - db-srv1

![](files/pic/14.png)

- Сосояние кластера MySQL через ProxySQL

![](files/pic/15.png)

- Добавляем новую запись в БД

![](files/pic/16.png)

- Проверяем записи в таблице на другой виртуалке MySQL

![](files/pic/17.png)

- Запускаем выключенную виртуалку проверяем состояние через ProxySQL

![](files/pic/18.png)

- Выключение виртуалки MySQL - db-srv3

![](files/pic/19.png)

- Сосояние кластера MySQL через ProxySQL

![](files/pic/20.png)

- Добавляем новую запись в БД

![](files/pic/21.png)

- Проверяем записи в таблице на другой виртуалке MySQL

![](files/pic/22.png)


- вывод terraform и ansible
  
- [terraform-output.txt](files/terraform-output.txt)
  
- [ansible-output.txt](files/ansible-output.txt)