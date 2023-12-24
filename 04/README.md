#  Копалев А. С. - Домашняя работа № 4

## Задача
Настройка конфигурации веб приложения под высокую нагрузку
#### Цель:
terraform (или vagrant) и ansible роль для развертывания серверов веб приложения под высокую нагрузку и отказоустойчивость
в работе должны применяться:
keepalived, (в случае использовать vagrant и virtualbox), load balancer от yandex в случае использования яндекс клауд
nginx,
uwsgi/unicorn/php-fpm
некластеризованная бд mysql/mongodb/postgres/redis
## Реализация
Для развертывания инфраструктуры использовался Terraform и Ansible.
Через Terraform в Yandex Cloud создаются следующие ресурсы (через модули):
- Облачная сеть - network1
- 3 подсети - subnet-1 и subnet-2, для сервера ISCSI, для виртуальных машин бэкенда, сервера БД и subnet-bast, для бастионного хоста
- 1 виртуальная машина bast-host-srv с внешним IP-адресом, доступная по SSH, реализующая SSH доступ к остальным виртуалкам
- DNS зону - zone1, A-запись для домена dip-akopalev.ru
- 1 виртуальная машина для сервера ISCSI с дополнительным диском
- 1 виртуальная машина для БД MySQL
- 2 виртуальные машины для бэкенда Wordpress
- 1 Yandex Application Load Balancer в качестве балансировщика

[main.tf](./main.tf)

Через Ansible реализуются 6 ролей:
 - "chrony" - установка и синхронизация времени на всех виртуальных машинах
 - "targetcli" - устанавливает targetcli, создает LUN, прописывает ACL клиентов (переменные зашифрованы через ansible-vault) для использования в качестве общей ФС gfs2 для бэкенд серверах, для хранения статики
 - "iscsi-client" - устанавливает iscsi-клиент, подключает LUN с сервера как блочное устройство 
 - "ha-cluster" - станавливает pacemaker, pcs, fence agent, lvm2, lvm2-lockd, dlm,gfs2-utils. Настраивает кластер, создает необходимые ресурсы, создает кластерную ФС.
 - "db" - устанавливает MySQL, задает пароль root, создает БД, пользователя и пароль для Wordpress (переменные зашифрованы через ansible-vault)
 - "wordpress" - устанавливает на бэкенд сервера nginx и каталог wordpress в директорию но общей ФС, заменяет их конфиги


[playbook.tf](./ansible/playbook.yml)

## Скриншоты из Yandex Cloud, созданного сайта, выводы при выполнении terraform apply и ansible-playbook playbook.yml

- созданные ресурсы в Yandex Cloud
  
![](files/pic/1.png)

- созданные виртуальные машины
  
![](files/pic/2.png)

- созданные сети
  
![](files/pic/3.png)

- созданные подсети
  
![](files/pic/4.png)

- группы безопасности
  
![](files/pic/5.png)

- открытые порты для группы безопасности external-sg

![](files/pic/6.png)

- открытые порты для группы безопасности internal-sg

![](files/pic/7.png)

- открытые порты для группы безопасности sec-bast-sg

![](files/pic/8.png)

- Используемые IP-адреса

![](files/pic/9.png)

- Балансировщик Yandex Application Load Balancer

![](files/pic/10.png)

- HTTP-роутер

![](files/pic/11.png)

- группа бэкендов

![](files/pic/12.png)

- Целевая группа

![](files/pic/13.png)

- балансировщик

![](files/pic/14.png)

- проверки состояния Application Load Balancer

![](files/pic/15.png)

- Карта балансировки

![](files/pic/16.png)

- DNS записи

![](files/pic/17.png)

- Завершение установки Wordpress

![](files/pic/18.png)

- Работа админки сайта

![](files/pic/19.png)

- Проверка работы сайта

![](files/pic/20.png)

- pcs status на одной из нод бэкенда

![](files/pic/21.png)

- lsbkl

![](files/pic/22.png)

- выключение бэкенд 2

![](files/pic/23.png)

- pcs status на второй ноде

![](files/pic/24.png)

- состояние виртуалок

![](files/pic/25.png)

- Проверки состояния Application Load Balancer

![](files/pic/26.png)

- Проверка работы админки сайта

![](files/pic/27.png)

- Проверка работы сайта

![](files/pic/28.png)

- включение бэкенд 2

![](files/pic/29.png)

- Проверки состояния Application Load Balancer

![](files/pic/30.png)

- pcs status

![](files/pic/31.png)

- Проверка работы админки сайта

![](files/pic/32.png)

- отключение бэкенд 1 и pcs status на бэкенд 2

![](files/pic/33.png)

- состояние виртуалок

![](files/pic/34.png)

- Проверки состояния Application Load Balancer

![](files/pic/35.png)

- Проверка работы админки сайта

![](files/pic/36.png)

- Проверка работы сайта

![](files/pic/37.png)

- включение бэкенд 1 и pcs status на бэкенд 2

![](files/pic/38.png)

- состояние виртуалок

![](files/pic/39.png)

- Проверки состояния Application Load Balancer

![](files/pic/40.png)

- Проверка работы админки сайта

![](files/pic/41.png)

- вывод terraform и ansible
  
- [terraform-output.txt](files/terraform-output.txt)
  
- [ansible-output.txt](files/ansible-output.txt)