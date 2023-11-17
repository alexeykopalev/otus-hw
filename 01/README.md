#  Копалев А. С. - Домашняя работа № 1

## Задача
Реализовать терраформ для разворачивания одной виртуалки в yandex-cloud;
Запровиженить nginx с помощью ansible.

## Реализация
Для развёртки инфраструктуры использовался Terraform и Ansible.
Через Terraform в Yandex Cloud создаются следующие ресурсы (через модули):
- Облачная сеть - network1
- 1 подсеть - subnet-1
- 1 виртуальная машина web-srv1 с внешним IP-адресом, доступ по SSH

Через Ansible устанавливается nginx и заменяется его конфиг (реализация через роли)

[main.tf](./main.tf)

[playbook.tf](./ansible/playbook.yml)

## Описание пошагового выполнения со скриншотами

- main.tf
  
![](pic/1.png)

- модуль создания сети и подсети
  
![](pic/2.png)

- модуль создания виртуалки
  
![](pic/3.png)

- playbook.yml
  
![](pic/4.png)

- роль установки и замены конфига nginx
  
![](pic/5.png)

- вывод terraform и ansible
  
-  [terraform-output.txt](./terraform-output.txt)
  
- [ansible-output.txt](./ansible-output.txt)
  
![](pic/6.png)

-   Скриншот из yandex cloud

![](pic/7.png)

- скриншот рабочего веб-сервера
  
![](pic/8.png)
