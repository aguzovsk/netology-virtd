# Домашнее задание к занятию «Продвинутые методы работы с Terraform»
## Задание 1.
![скриншот консоли Yandex Cloud с созданными ВМ](./items/Task1-1.png)
![скриншот выполнения команды sudo nginx -t](./items/Task1-2.png)
![terraform console](./items/Task1-3.png)


## Задание 2.
3.
![скриншот консоли выполенной команды в terraform console > module.simple_vpc](./items/Task2_3.png)

4.
```bash
terraform destroy
terraform apply -target module.simple_vpc
terraform apply -target module.vm
```

5.
[Документация](https://terraform-docs.io/user-guide/installation/#docker)
![скриншот консоли выполенной командой 2.5](./items/Task2_5.png)

## Задание 3.

1-3 \
![скриншот консоли выполенных команд](./items/Task3.png)

4.
Нужно закоментировать другие модули (использующие обращение к local.network_id & local.subnets) в other/main.tf,
а также в other/locals.tf local.network_id & local.subnets. \
Т.к., скорее всего, отдельный root-модуль vpc не запущен (т.к. используется "локальный" simple_vpc модуль) 
![Импорт модуля сети](./items/Task3_4-1.png)
![Импорт модуля вм](./items/Task3_4-2.png)
Невозможно импортировать data source
![Ошибка при импорте](./items/Task3_4-3.png)

Результат применения terraform apply
```bash
terraform apply -target module.simple_vpc
terraform apply -target module.vm
```
![terraform apply -target ...](./items/Task3_4-4.png)
 

## Задание 4+8.
VPC создан как отдельный root-модуль (Задание 8) \
![скриншот консоли с планом выполнения задания 4](./items/Task4(8)-1.png)
![скриншот консоли Yandex Cloud задания 4](./items/Task4(8)-2.png)

## Задание 5.
1.
Создание MySQL cluster
```bash
terraform apply -target module.mysql_5.module.cluster_mysql
```
![скриншот консоли с планом выполнения задания 5.1](./items/Task5_1-1.png)
![скриншот консоли с terraform state задания 5.1](./items/Task5_1-2.png)

2.
Создание managed БД Mysql
```bash
terraform apply -target module.mysql_5.module.db_mysql
```
![скриншот консоли с планом выполнения задания 5.2](./items/Task5_2-1.png)
![скриншот консоли с terraform state задания 5.2](./items/Task5_2-2.png)

3.
Создание MySQL cluster и managed БД Mysql
```bash
terraform apply -target module.mysql_5
```
![скриншот консоли с планом выполнения задания 5.3 (полное создание)](./items/Task5_3-1.png)
![скриншот консоли с планом выполнения задания 5.3 (изменение, добавление новой вм)](./items/Task5_3-2.png)
![скриншот Yandex Console с выполнением задания 5.3 (изменение, добавление новой вм)](./items/Task5_3-3.png)
![скриншот консоли с terraform state задания 5.3 (новая вм добавлена)](./items/Task5_3-4.png)
![скриншот Yandex Console с выполнением задания 5.3 (новая вм добавлена)](./items/Task5_3-5.png)


## Задание 6.
terraform apply -target module.s3_keys_6 \
export AWS_PROFILE={...} \
terraform apply -target module.s3 \
![скриншот терминала при создании S3 bucket с помощью yandex s3 модуля](./items/Task6.png)

## Задание 7
![скриншот терминала выполнения задания №7](./items/Task7.png)
