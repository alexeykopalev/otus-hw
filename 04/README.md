#  Копалев А. С. - Домашняя работа № 3

## Задача
Научиться использовать Nginx в качестве балансировщика.
Развернуть 4 виртуалки терраформом в яндекс облаке:
1 виртуалка - Nginx - с публичным IP адресом,
2 виртуалки - бэкенд на выбор студента ( любое приложение из гитхаба - uwsgi/unicorn/php-fpm/java) + nginx со статикой,
1 виртуалкой с БД на выбор mysql/mongodb/postgres/redis.
## Реализация
Для развёртки инфраструктуры использовался Terraform и Ansible.
Через Terraform в Yandex Cloud создаются следующие ресурсы (через модули):
- Облачная сеть - network1
- 2 подсети - subnet-1, для виртуальных машин бэкенда и сервера БД и subnet-bast, для бастионного хоста
- 1 виртуальная машина bast-host-srv с внешним IP-адресом, доступная по SSH, реализующая SSH доступ к остальным виртуалкам
- DNS зону - zone1, A-запись для домена dip-akopalev.ru
- 1 виртуальная машина для БД MySQL
- 1 виртуальная машина для Nginx в качестве балансировщика
- 2 виртуальные машины для бэкенда Wordpress

[main.tf](./main.tf)

Через Ansible реализуются 3 роли:
 - "db" - устанавливает MySQL, задает пароль root, создает БД, пользователя и пароль для Wordpress (переменные зашифрованы через ansible-vault)
 - "wordpress" - устанавливает на бэкенд сервера nginx и wordpress, заменяет их конфиги
 - "loadbalancer" - устанавливает nginx и настраивает его в качестве балансировщика.

[playbook.tf](./ansible/playbook.yml)

## Скриншоты из Yandex Cloud, созданного сайта, выводы при выполнении terraform apply и ansible-playbook playbook.yml

- созданные ресурсы в Yandex Cloud
  
![](files/pic/1.png)

- созданные виртуальные машины
  
![](files/pic/2.png)

- группы безопасности
  
![](files/pic/3.png)

- открытые порты для группы безопасности internal-sg
  
![](files/pic/4.png)

- открытые порты для группы безопасности external-sg
  
![](files/pic/5.png)

- открытые порты для группы безопасности sec-bast-sg

![](files/pic/6.png)

- подсети

![](files/pic/7.png)

- DNS записи

![](files/pic/8.png)

- Завершение установки Wordpress

![](files/pic/9.png)

- Работа админки сайта

![](files/pic/10.png)

- Работа сайта

![](files/pic/11.png)

- выключение одной из виртуалок бэкенда

![](files/pic/12.png)

- Состояние виртуалок в Yandex Cloud

![](files/pic/13.png)

- Проверка работы админки сайта

![](files/pic/14.png)

- Проверка работы админки сайта

![](files/pic/15.png)

- выключение другой виртуалки бэкенда

![](files/pic/16.png)

- Проверка работы сайта

![](files/pic/17.png)

- вывод terraform и ansible
  
- [terraform-output.txt](files/terraform-output.txt)
  
- [ansible-output.txt](files/ansible-output.txt)