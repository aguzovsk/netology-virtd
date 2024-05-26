# Домашнее задание к занятию «Использование Terraform в команде»

## Задание 1.
```bash
# run from netology-devops/terraform/homework-05 directory
docker run --rm --tty --volume $(pwd)/task1:/tf bridgecrew/checkov \
   --download-external-modules true --directory /tf
```
сheckov:
* Check: CKV_TF_1: "Ensure Terraform module sources use a commit hash"
* Check: CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"

С флагом **--download-external-modules true**:
* Check: CKV_YC_2: "Ensure compute instance does not have public IP."
* <span style="color: green; font-weight: bold">PASSED:</span> Check: CKV_YC_4: "Ensure compute instance does not have serial console enabled."
* Check: CKV_YC_11: "Ensure security group is assigned to network interface."

_(Найдены только в папке demonstration1)_

```bash
# run from netology-devops/terraform/homework-05 directory
docker run --rm -t -v "$(pwd)/task1:/tflint" --workdir /tflint  ghcr.io/terraform-linters/tflint "--recursive"
```

<details>
<summary>Альтернативно</summary>

```bash
# run from netology-devops/terraform/homework-05 directory
docker run --rm -t -v "$(pwd)/task1:/tflint" --entrypoint=/bin/sh  ghcr.io/terraform-linters/tflint -c "cd /tflint; tflint --recursive"
# OR
docker run --rm -t -v "$(pwd)/task1:/tflint" ghcr.io/terraform-linters/tflint "--chdir" "/tflint/src"; \
docker run --rm -t -v "$(pwd)/task1:/tflint" ghcr.io/terraform-linters/tflint "--chdir" "/tflint/demonstration1"
```
</details>

tflint:
* Warning: Module source "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main" uses a default branch as ref (main) (terraform_module_pinned_source)
* Warning: Missing version constraint for provider "template" in `required_providers` (terraform_required_providers)
* Warning: [Fixable] variable "public_key" / "vms_ssh_root_key" / "vm_web_name" / "vm_db_name" is declared but not used (terraform_unused_declarations)

## Задание 2.

#### Пункт 2.
<details>
<summary>Ответ</summary>

S3 Bucket и YDB создаются в коде (см. [Задание №7](#задание-7))

* Миграция **terraform.tfstate** в S3 bucket \
![](./items/Task2_2-2.png)
* S3 bucket после миграции \
![](./items/Task2_2-1.png)
</details>

#### Пункты 4-6.
<details>
<summary>Ответ</summary>

* Запущен **terraform destroy**, который ожидает исполнения \
![Задерка lock](./items/Task2_4-1.png)
* Попытка захватить lock, а также разные способы его разблокировки \
![Попытка захватить lock](./items/Task2_4-2.png)
</details>

## Задание 3.

### Checkov homework-04

```bash
# run from netology-devops/terraform directory
docker run --rm --tty --volume $(pwd)/homework-04:/tf bridgecrew/checkov \
   --download-external-modules true --directory /tf
```

<details>
<summary>Скриншоты</summary>

![checkov homework-04 screenshot](./items/Task3-checkov-04-errors.png)
![checkov homework-04 screenshot no errors](./items/Task3-checkov-04-corrected.png)
</details>

Ошибки (некоторые файлы могут быть пропущены):
* Check: CKV_YC_2: "Ensure compute instance does not have public IP." \
Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/bc-aws-2-40
    + resource: module.vm.module.analytics.yandex_compute_instance.vm[0]  \
    Calling File: /other/1_cloud_init/main.tf:20-37
    + resource: module.vm.module.marketing.yandex_compute_instance.vm[0] \
    Calling File: /other/1_cloud_init/main.tf:1-18
* Check: CKV_YC_11: "Ensure security group is assigned to network interface."
    + resource: module.vm.module.analytics.yandex_compute_instance.vm[0] \
    Calling File: /other/1_cloud_init/main.tf:20-37
    + resource: module.vm.module.marketing.yandex_compute_instance.vm[0] \
    Calling File: /other/1_cloud_init/main.tf:1-18
* Check: CKV_TF_1: "Ensure Terraform module sources use a commit hash" \
Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/supply-chain-policies/terraform-policies/ensure-terraform-module-sources-use-git-url-with-commit-hash-revision
    + File: /other/1_cloud_init/main.tf:1-20
    + File: /other/main.tf:57-90
* Check: CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
    + Calling File: /other/main.tf:10-16
* Check: CKV_YC_1: "Ensure security group is assigned to database cluster." \
    + File: /other/5_mysql/modules/mysql_cluster/main.tf:17-46
* Check: CKV_SECRET_6: "Base64 High Entropy String" \
Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/secrets-policies/secrets-policy-index/git-secrets-6
    + File: /other/7_vault/terraform.tf:4-5 \
    Ошибка была подавлена, т.к. данный токен использовался в учебных целях
    #checkov:skip=CKV_SECRET_6:Base64 High Entropy String

### Checkov homework-05/s3-tfstate

```bash
# run from netology-devops/terraform directory

docker run --rm --tty --volume $(pwd)/homework-05/s3-tfstate:/tf bridgecrew/checkov \
   --download-external-modules true --directory /tf
```

<details>
<summary>Скриншоты</summary>

![checkov homework-05 screenshot](./items/Task3-checkov-05-errors.png)
![checkov homework-05 screenshot no errors](./items/Task3-checkov-05-corrected.png)
+ **terraform apply**: KMS SSE
![KMS SSE applied](./items/Task3-checkov-05-s3-sse-applied.png)
</details>

Ошибки:
* Check: CKV_YC_3: "Ensure storage bucket is encrypted."
    + File: /main.tf:11-36

### TFLint homework-04 + homework-05/s3-tfstate

```bash
# run from netology-devops/terraform directory

docker run --rm -v "$(pwd)/homework-04:/tflint" --workdir /tflint ghcr.io/terraform-linters/tflint --recursive
docker run --rm -v "$(pwd)/homework-05/s3-tfstate:/tflint" --workdir /tflint ghcr.io/terraform-linters/tflint --recursive
```

<details>
<summary>Скриншоты</summary>

![homework-04 errors](./items/Task3-tflint-04-errors.png)
![s3 module errors](./items/Task3-tflint-05-errors.png)
![no tflint errors](./items/Task3-tflint-correct.png)
</details>

### Результат

Согласно **checkov** были добавлены Security Group, вместо ветки на github для remote-модулей используется hash commit'а и другие мелочи.
Таке согласно рекомендациям было включено шифрование в Yandex S3. В [Задании 7](#задание-7) были произведены изменения.\
\
Был запущен модуль для хранения remote-state (homework-05/s3-tfstate). В нём хранит state модуль vpc (homework-04/vpc) используя один service account,
а считывает данные из этого state, с помощью terraform_remote_state, другой модуль (homework-04/other/1_cloud_init), используя другой service account.

<details>
<summary>Скриншоты</summary>

* Отдельный root-модуль vpc использует remote state S3\
На скриншоте показано, как terraform делает lock release
![terraform apply vpc with lock released](./items/Task3-final-vpc.png)

* terraform apply -target module.vm\
Запущен модуль из homework-04/other, который считывает информацию о подсетях с помощью terraform_remote_state из Yandex S3\
Согласно **checkov** также в модуль была добавлена Security Group
![terraform apply vms, with fetching data from remote state](./items/Task3-final-vms.png)
</details>

### Off-topic

<details>
<summary>coalesce bug</summary>

В ходе разработки был найден bug, **terraform console**: (v1.5.7):\
\> coalesce(null, "", {a = null, b = ""}, "some")\
""\
\> coalesce(null, "")\
<span style="color: red; font-weight: bold">Error:</span> Error in function call\
\> coalesce(null, "", "some")\
"some"\
\> coalesce(null, "", "some", {a = null, b = ""})\
""\
\> coalesce(null, "", "some", {})\
""\
> coalesce(null, "", "some", [])\
""

![coalesce-bug](./items/console-coalesce-bug.png)
</details>

### Дополнение:

Обновление до terraform v1.8.4, тест:
1. Запущен homework-05/s3-tfstate как remote state s3 backend
2. Запущен homework-04/vpc как отдельный root-модуль с remote state backend из предыдущего пункта
3. Запущен homework-04/other, кроме (были закоментированы в коде):
    * 2_vpc (simple_vpc), т.к. уже создан VPC
    * s3 module (terraform-yc-s3), т.к. ещё не сгенерирован static_key для service account
4. После выполнения homework-04/other был сгенерирован static access key и был запущен s3 module (terraform-yc-s3) - раскоментирован.

<details>
<summary>Скриншот выполненного пункта 3.</summary>

![full screenshot](./items/Task3-hw04-other-except-s3.png)
</details>

<details>
<summary>Скриншот выполненного пункта 4.</summary>

![screenshot](./items/Task3-hw04-other-s3.png)
</details>

Поведение **coalesce** такое же как и в v1.5.7 


## Задание 4+5.
<details>
<summary>Скриншоты</summary>

![Всё неверно 1](./items/Task4-wrong-1.png)
![Всё неверно 2](./items/Task4-wrong-2.png)
![Всё верно, кроме XOR](./items/Task4-correct-part.png)
![Всё верно, даже XOR](./items/Task4-two-xor.png)
</details>

## Задание 7.
### Создание и конфигурация S3
Поскольку создание S3 bucket происходит в коде, а также здесь даются права, то создающий S3 bucket должен обладать, как минимум **storage.admin** правами доступа. 
Поэтому нужно хотя бы минимальное разделение ролей. \
Используется 3 Service Account:
* storage.admin — создаёт S3 bucket даёт права доступа и настраивает его
* storage.uploader (в коде как user)\
Хранит свой terraform state в Yandex S3
* storage.viewer — может просматривать Yandex S3, но не может туда записывать.\
Используется для считывания с помощью terraform_remote_state data source

Не использую [terraform-yc-s3](https://github.com/terraform-yc-modules/terraform-yc-s3) модуль, т.к. не вижу особой необходимости, а он добавляет дополнительную зависимость — AWS CLI, хотя от этой зависимости не удалось отказаться в итоге.\
\
Включено шифрование Yandex S3 bucket: SSE-KMS симметричным ключом AES-192.

### Создание и конфигурация YDB
Т.к. в YDB не поддерживается такое же разделение ролей как и в YC S3, то здесь я этого не делал. \
\
Невозможно создать **Document table** из terraform. [Yandex Provider](https://terraform-provider.yandexcloud.net/Resources/ydb_table) v0.119.0  поддерживает создание только YDB Row Tables. \
В документации есть только primary_key, но нет partition_key, разве что подразумевается, что это одно и тоже.
(актуально для yandex [v0.119.0](https://registry.terraform.io/providers/yandex-cloud/yandex/0.119.0/docs/resources/ydb_table)) \
\
Делал попытки ([см.код.](./s3-tfstate/ydb.tf#L41)) "мимикрировать" под Document table, подставляя нужные аттрибуты (которые скопировал при **terraform import**), но не получилось. 
Выдаёт ошибку: "Document API table cannot be modified from YQL query" и прочие. \
\
В YC CLI [v0.125.0] нет возможности создания таблицы (table) в YDB (можно создать только database). \
Зато можно создать через AWS CLI, как это описано в [документации](https://yandex.cloud/en/docs/ydb/docapi/tools/aws-cli/create-table). 
Что и было сделано через скрипт в [terraform_data](./s3-tfstate/main.tf#L71). \
\
Пример с YDB Document table [код](https://github.com/yandex-cloud-examples/yc-serverless-ydb-api/blob/main/main.tf#L28) 
([permalink](https://github.com/yandex-cloud-examples/yc-serverless-ydb-api/blob/c5bf360de6a07b8ba4b98e359a36f169d68ece09/main.tf#L28)) —
используется такой же подход как и у меня (через скрипт + AWS CLI).

<details>
<summary>Ошибки при "мимикрировании"</summary>

+ **terraform import** Document-based YDB table \
![](./items/Task7-terraform-import.png)
+ **terraform replace** Попытка сделать replace Document-based YDB таблицы. \
YC provider не может даже удалить Document YDB table. \
![](./items/Task7-terraform-replace.png)
+ Попытка создания Document-based YDB таблицы (копируя аттрибуты Document-based YDB таблицы) ([код (закоментированный)](./s3-tfstate/ydb.tf#L41)) \
![](./items/Task7-terraform-apply.png)
+ YDB YC Web-Console \
![](./items/Task7-ydb-yc-console.png)
+ Созданная таблица оказалась Row-based \
![](./items/Task7-row-table.png)
+ Row-based YDB таблицу нельзя использовать для terraform state lock
</details>


### Работа с Yandex S3 с включенным версионированием
Может возникнуть потребность вручную через Yandex Web-console удалить bucket. Но, если файл туда уже загружен, то удаяляя фал (объект) его через Yandex Web-Console (и Вы не приостановили версионирование преждевременно) Вы только добавляете маркер удаления. (Можно сделать и через Web-консоль включив переключатеь (в верху UI))

* Вывести версии объектов в S3 bucket:
```bash
aws --endpoint-url=https://storage.yandexcloud.net/ \
   --profile {aws-profile-name} \
   s3api list-object-versions \
   --bucket {your-bucket-name}
```

<details>
<summary>Результат команды (список версий объектов)</summary>

```json
{
    "Versions": [
        {
            "ETag": "\"b24561462b7398a0f28cf2b475ed407c\"",
            "Size": 6189,
            "StorageClass": "STANDARD",
            "Key": "terraform.tfstate",
            "VersionId": "0006190E456DBCFA",
            "IsLatest": false,
            "LastModified": "2024-05-22T17:29:05.320000+00:00",
            "Owner": {
                "DisplayName": "${yandex-id-of-length-20}",
                "ID": "${yandex-id-of-length-20}"
            }
        }
    ],
    "DeleteMarkers": [
        {
            "Owner": {
                "DisplayName": "${yandex-id-of-length-20}",
                "ID": "${yandex-id-of-length-20}"
            },
            "Key": "terraform.tfstate",
            "VersionId": "00061919F63DDF8A",
            "IsLatest": true,
            "LastModified": "2024-05-23T07:25:56.390000+00:00"
        }
    ],
    "RequestCharged": null
}
```
</details>

* Удалить версию объекта (в том числе маркер удаления):

```bash
aws --endpoint-url=https://storage.yandexcloud.net/ \
   --profile {aws-profile-name} \
   s3api delete-object \
   --bucket {your-bucket-name} \
   --key {terraform.tfstate} \
   --version-id {0006190E456DBCFA}
```

Удалить все версии объектов Yandex S3 bucket object  storage (должен быть установлен jq):
```bash
aws --endpoint-url=https://storage.yandexcloud.net/ \
   --profile {profile-name} \
   s3api list-object-versions \
   --bucket {bucket-name} \
   | jq '.DeleteMarkers[], .Versions[] | {Key, VersionId} | "\(.Key | @sh) \(.VersionId | @sh)"' | \
sed s/\"//g | awk '{system( \
"aws --endpoint-url=https://storage.yandexcloud.net/ \
   --profile {profile-name} \
   s3api delete-object \
   --bucket {bucket-name} \
   --key " $1 " \
   --version-id " $2 \
)}'
```

<details>
<summary>Объяснение</summary>

1. aws s3api list-object-versions скачиваем версии
2. jq:
    * Из json объекта выбираем поля-массивы DeleteMarkers и Versions и объединяем их
    * Каждый элемент в объединённом массиве содержит поля Key и VersionId, которые нам нужны
    * используем встроенную функцию @sh для экранирования полей и для каждого объекта делаем строку
3. sed - убираем кавычки которые нам нужны были для построения строк внутри jq
4. awk:
С помощью system вызываем bash-statement 
</details>

* Удалив верcии объекта можно удалить bucket из Yandex Web-Console. Или так:
```bash
aws --endpoint-url=https://storage.yandexcloud.net/ \
   --profile {aws-profile-name} \
   s3api delete-bucket \
   --bucket {your-bucket-name}
```

### Работа с Yandex YDB через AWS CLI

```bash
export endpoint="${DOC_API_ENDPOINT}"

aws dynamodb list-tables \
  --endpoint $endpoint \
  --profile ${AWS_PROFILE}

aws dynamodb describe-table \
  --endpoint $endpoint \
  --profile ${AWS_PROFILE} \
  --table-name ${YDB_TABLE_NAME}

# Use SCAN operation only on small dataset and/or apply filter option
# --filter-expression <value>
aws dynamodb scan \
  --endpoint $endpoint \
  --profile ${AWS_PROFILE} \
  --table-name ${YDB_TABLE_NAME}

aws dynamodb get-item \
  --endpoint $endpoint \
  --profile ${AWS_PROFILE} \
  --table-name ${YDB_TABLE_NAME} \
  --key '{ "LockID": {"S": "${string}"}}'

aws dynamodb delete-item \
  --endpoint $endpoint \
  --profile ${AWS_PROFILE} \
  --table-name {YDB_TABLE_NAME} \
  --key '{ "LockID": {"S": "${string}"}}'
```
