# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»
## Задание 1.
![скриншот ЛК Yandex Cloud «Группы безопасности»](./items/Task1-0.png)
![скриншот ЛК Yandex Cloud входящих правил «Группы безопасности»](./items/Task1-1.png)

## Задание 4.
![скриншот отрендеренного template файла (hosts.ini), также Задание 6](./items/Task4.png)

## Задание 5.
![скриншот консоли с Outputs после создания](./items/Task5.png)

## Задание 7.
{ for key, value in local.vpc : key => try(matchkeys(value, [1, 1, 0, 1], [1]), value) }
![скриншот terraform console](./items/Task7.png)

## Задания 2, 3, 6
В коде
