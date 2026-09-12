# Kyotika Web

京都のランドマーク一覧を表示する Rails アプリケーション。

## 環境要件

- Ruby 4.0.3
- Rails 8.1.3.1
- SQLite

## セットアップ

```bash
bin/rails db:create db:migrate db:seed
```

- `db:seed` は任意（投入なしでも動作する。投入分は未割当として管理者のみ閲覧可）
- `db:seed` は冪等（再実行しても既存行は変更されない）
- 注意：`db:seed:replant` は users・アカウントごと全テーブルを消去するため、本番では使用しないこと

## サーバー起動

```bash
bin/rails server
```

http://localhost:3000 でアクセス

## クイズ

京都のランドマークについてのクイズに挑戦できます。

### 使い方

1. トップページから「クイズ」を選択
2. 問題数を選択
3. 「スタート」をクリック
4. 各問題に回答
5. 結果ページで正解率を確認

## タスク

### URL チェック

全 landmark の URL を検証し、結果を DB にキャッシュします。

```bash
bin/rails landmarks:check_urls
```

- 各 URL に GET リクエストを送信
- ステータスを `url_status` カラムに保存
- チェック日時を `url_checked_at` カラムに保存

### HTTPS 変換

対象の HTTP URL を HTTPS に変換します。

```bash
bin/rails landmarks:upgrade_to_https
```

### seed データ再読み込み

テーブルを Truncate してから seed を再実行します。

```bash
bin/rails db:seed:replant
```

## アカウント管理

ランドマーク・タグの追加編集削除はログイン必須。ロールは管理者とメンバー。

### 初回起動

ユーザーが0人の状態でログイン画面を開くと、最初の管理者作成画面に転送される。

1. `/first_run` で管理者アカウントを作成（seed 投入の前後どちらでも可）
2. seed を投入する場合は `bin/rails db:seed`（投入分は未割当になり管理者のみ閲覧可）
3. メンバー管理画面の招待URLを共有し、メンバーを登録する
4. 管理者は常時2人以上を推奨（単独管理者のパスワード忘れに備える）

### メンバー招待

1. 管理者でログインし「メンバー管理」を開く
2. 招待URLをメンバーに共有（再生成するまで何度でも利用可）
3. メンバーは招待URLから自己登録（ロールはメンバー固定）

### パスワードを忘れた場合

- メンバー：管理者に連絡し、メンバー管理画面で仮パスワードを発行してもらう
- 仮パスワードでログイン後、プロフィール画面で本パスワードに変更する

### 緊急時（管理者がログインできない場合）

メール送信機能はないため、サーバーのコンソールから直接再設定する。

```bash
bin/rails console
user = User.find_by(email_address: "管理者のメールアドレス")
user.update!(password: "仮パスワード", password_confirmation: "仮パスワード")
```

- 本番（Render）はダッシュボードの Shell から同手順で実行する
- 復旧後は本人にプロフィール画面でパスワードを変更させる

## データ構造

### Landmarks テーブル

| カラム | 型 | 説明 |
|---|---|---|
| id | integer | ID |
| name | string | 名前 |
| hiragana | string | 読み（ひらがな） |
| latitude | float | 緯度 |
| longitude | float | 経度 |
| url | string | URL |
| question | string | クイズ問題 |
| answer1 | string | 回答1 |
| answer2 | string | 回答2 |
| answer3 | string | 回答3 |
| correct | integer | 正解（1-3） |
| creator_id | integer | 登録者（users への参照、空は未割当） |
| region_id | integer | 地域（regions への参照） |
| url_status | string | URL ステータス（valid/invalid_xxx/error_xxx） |
| url_checked_at | datetime | URL チェック日時 |

### Regions テーブル

| カラム | 型 | 説明 |
|---|---|---|
| id | integer | ID |
| name | string | 地域名（一意） |
| hiragana | string | 読み（ひらがな、ソート用） |

### Tags テーブル

| カラム | 型 | 説明 |
|---|---|---|
| id | integer | ID |
| name | string | タグ名 |

### Taggings テーブル

| カラム | 型 | 説明 |
|---|---|---|
| id | integer | ID |
| landmark_id | integer | ランドマーク ID |
| tag_id | integer | タグ ID |
