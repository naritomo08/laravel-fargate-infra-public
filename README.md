# laravel-fargate-infra-public

ECR/ECSを立ち上げるためのインフラ部分になります。

## 構築環境

GitHubActionからビルドを受ける、インフラ環境になります。

```bash
アプリ稼働:
ECR/ECS

DB:
RDB(MySQL)/Redis

ネットワーク:
ALB/SSL
```

## 参照書籍/サイト

[TerraformでFargateを構築してGitHub Actionsでデプロイ！Laravel編](https://www.amazon.co.jp/gp/product/B09GFB67X1/ref=ppx_yo_dt_b_d_asin_title_o00?ie=UTF8&psc=1)

[UbuntuでAWS CLIを使えるようにする](https://qiita.com/SSMU3/items/ce6e291a653f76ddcf79)

[ubuntuにHomebrewをインストール](https://zenn.dev/akgcog/articles/2e63b33ee3001a)

[【初心者向け】MacにTerraform環境を導入してみた](https://dev.classmethod.jp/articles/beginner-terraform-install-mac/)

[【Route53】AWS上で独自ドメインを取得する方法について解説](https://engineer-life.dev/aws-route53-domain/)

[ECSアプリ構築](https://github.com/naritomo08/laravel-fargate-app-public)

## 事前作業

以下のコマンドを利用できている状態になっていること。
```bash
aws

brew
*Terraform導入時に必要

tfenv
terraform
```

## 利用方法

### ソースを入手する。

以下のgitコマンドで入手する。

```bash
git clone https://github.com/naritomo08/laravel-fargate-infra-public.git laravel-fargate-infra
cd laravel-fargate-infra
rm -rf .git
```

### 指定バージョン(1.1.3)のterraformを導入する。

```bash
tfenv install
```

### ドメイン名設定

Rout53にて外向けドメインを入手し、
以下のファイル内のドメイン名設定を実施する。

```bash
vi envs/prod/routing/appfoobar_link/route53.tf
name = "<外向けドメイン名>"を書き換える。
```

### s3バケット名、dynamodb名変更

全てのソースから以下の名前になっているS3バケット名/dynamodb名を置換する。
特にs3については他の方が使用していない名前にする必要がある。

```bash
S3:
terraform-state

dynamodb:
terraform_state_lock
```

### インフラモジュール構築

以下の順番で構築すること。

```bash
tfstate用S3
cd tfstate
terraform init
terraform plan
terraform apply

ネットワーク周り作成
cd ../envs/prod/network/main
terraform init
terraform plan
terraform apply

ALB用ログ取得S3作成
cd ../../log/alb
terraform init
terraform plan
terraform apply

DBロググループ
cd ../../log/db_foobar
terraform init
terraform plan
terraform apply

Laravelロググループ
cd ../../log/app_foobar
terraform init
terraform plan
terraform apply

SSL証明書/DNSCNAME/ALB作成
cd ../../routing/appfoobar_link
terraform init
terraform plan
terraform apply

ECR/ECS/.env用S3作成
cd ../../app/foobar
terraform init
terraform plan
terraform apply

AIMユーザ/ポリシー/ecspresso設定作成
cd ../../cicd/app_foobar
terraform init
terraform plan
terraform apply
```

作成コマンド解説:
```bash
terraform init
*初回構築実行のみ

terraforn plan
*作成前の確認コマンド
*確認失敗が出た場合適宜対応すること。

terraform apply
terraform apply -target <モジュール名>
*作成失敗が出た場合適宜対応すること。
```

### RDSを作成する

```bash
cd ../../db/foobar
terraform init
terraform plan
terraform apply
*12分近くかかる。
```

### RDS/SystemsManagerへのDBパスワード登録

```bash
＊DB起動時に実施すること。
aws rds modify-db-instance \
--db-instance-identifier "example-prod-foobar" \
--master-user-password "Passw0rd"

＊以下のコマンドは初期構築のみでよい。
aws ssm put-parameter \
--name "/example/prod/foobar/DB_PASSWORD" \
--type "SecureString" \
--value "Passw0rd"
```

### Redisを作成する

```bash
cd ../../cache/foobar
terraform init
terraform plan
terraform apply
*14分近くかかる。
```

### Redis/RDS CNAMEレコードを作成する
```bash
cd ../../routing/foobar_internal
terraform init
terraform plan
terraform apply
```

### APP側のデプロイ実施

APP側ソース(terraform-fargate-app)に移動し、
ローカル環境構築、
mainブランチコミットによるデプロイを実施する。

[ECSアプリ構築](https://github.com/naritomo08/laravel-fargate-app-public)

## サービス一時削除/起動方法

一時削除の際は次の項目から実施し、起動の際は反対から行う。

余計な課金を防ぐため、なるべく環境を使用しない際は本作業で削除しておくとよい。

状況によってはRDS/Redis/CNAMEレコードを残してもよい。

### ECSサービス削除/起動

サービス起動後、タスクが自動的に起動しないため、アプリブランチでのmainブランチコミット
でタスクを立ち上げること。

またはgithubのActionページから最近実行したActionを動かすこと。

```bash
cd laravel-fargate-infra/envs/prod/app/foobar
terraform destroy -target aws_ecs_service.this
terraform apply
```

### Redis/RDS CNAMEレコード削除/起動
```bash
cd laravel-fargate-infra/envs/prod/routing/foobar_internal
terraform destroy
terraform apply
```

### Redis削除/起動

```bash
cd laravel-fargate-infra/envs/prod/cache/foobar
terraform destroy
terraform apply
*14分近くかかる。
```

### RDS削除/起動

```bash
cd laravel-fargate-infra/envs/prod/db/foobar
terraform destroy
terraform apply
*12分近くかかる。
```

### RDS/SystemsManagerへのDBパスワード登録

```bash
＊RDS起動時に実施すること。
aws rds modify-db-instance \
--db-instance-identifier "example-prod-foobar" \
--master-user-password "Passw0rd"

＊以下のコマンドは初期構築のみでよい。
aws ssm put-parameter \
--name "/example/prod/foobar/DB_PASSWORD" \
--type "SecureString" \
--value "Passw0rd"
```

### ALB削除/起動

```bash
cd laravel-fargate-infra/envs/prod/routing/appfoobar_link
terraform apply -var='enable_alb=false'
terraform apply
```

### NAT削除/起動

```bash
cd laravel-fargate-infra/envs/prod/network/main
terraform apply -var='enable_nat_gateway=false'
terraform apply
```

## 環境の消し方

### ECSサービスを削除する。

```bash
cd laravel-fargate-infra/envs/prod/app/foobar
terraform destroy -target aws_ecs_service.this
```

### Redis/RDS CNAMEレコードを削除する。
```bash
cd ../../routing/foobar_internal
terraform destroy
terraform state list
```

### Redisを削除する。

```bash
cd ../../cache/foobar
terraform destroy
→6分かかる
terraform state list
```

### RDSを削除する。

```bash
cd ../../db/foobar
terraform destroy
→6分かかる
terraform state list
```

### ALBを削除する。

```bash
cd ../../routing/appfoobar_link
terraform apply -var='enable_alb=false'
```
### NATを削除する。

```bash
cd ../../network/main
terraform apply -var='enable_nat_gateway=false'
```

### ECSデプロイ用アカウントアクセスキー削除

AWS IAM管理画面から、example-prod-foobar-githubユーザの
アクセスキーを削除する。

### その他モジュール削除(Terraform)

以下の順番で削除すること。

```bash

AIMユーザ/ポリシー/ecspresso設定
cd ../../cicd/app_foobar
terraform destroy
terraform state list

Laravelロググループ
cd ../../log/app_foobar
terraform destroy
terraform state list

DBロググループ
cd ../../log/db_foobar
terraform destroy
terraform state list

ECR/ECS/.env用S3
cd ../../app/foobar
terraform destroy
terraform state list

SSL証明書/DNSCNAME/ALB
cd ../../routing/appfoobar_link
terraform destroy
terraform state list

ALB用ログ取得S3
cd ../../log/alb
terraform destroy
terraform state list

ネットワーク周り
cd ../../network/main
terraform destroy
terraform state list

tfstate用S3
cd
cd laravel-fargate-infra/tfstate
terraform destroy
terraform state list
```

削除コマンド解説
```bash
terraform destroy
terraform destroy -target <モジュール名>

以下のコマンドを入力して、残っているモジュールがないことも確認すること。

terraform state list
リスト確認
結果で残っているモジュールがないか確認できる。
残っているものがある場合"aws_"で始まるモジュールを削除するか、
管理コンソール画面から手動で削除すること。
```

### 削除しきれていないモジュールの削除

AWS IAM管理画面に入り、以下の設定を削除する。

```bash
ロール:
AWSServiceRoleForECS
AWSServiceRoleForElastiCache
AWSServiceRoleForElasticLoadBalancing
AWSServiceRoleForRDS
```

### 作業フォルダ削除する。

```bash
sudo rm -rf laravel-fargate-infra
```

### アプリ側の削除を実施する。

APP側ソース(terraform-fargate-app)に移動し、
アプリ側の削除を実施する。

[ECSアプリ構築](https://github.com/naritomo08/laravel-fargate-app-public)

### 課金確認

1日放置して、課金されているところがないか確認する。

