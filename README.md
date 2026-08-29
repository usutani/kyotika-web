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

## サーバー起動

```bash
bin/rails server
```

http://localhost:3000 でアクセス

## クイズ

京都のランドマークについてのクイズに挑戦できます。

### 使い方

1. トップページから「クイズ」を選択
2. 問題数を選択（デフォルトは全問題）
3. 「スタート」をクリック
4. 各問題に回答
5. 絢果ページで正解率を確認

### 問題数の指定

URL パラメータで問題数を指定できます：

```
http://localhost:3000/quiz?count=5
```

または、畫面の入力欄で問題数を変更してスタートできます。

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
| author | string | 著者 |
| url_status | string | URL ステータス（valid/invalid_xxx/error_xxx） |
| url_checked_at | datetime | URL チェック日時 |

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
