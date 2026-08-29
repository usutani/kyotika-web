# AGENTS.md

## アーキテクチャ

- Rails 8.1 + Hotwire/Turbo（SPA ライクな体験）
- Quiz はセッションベース（DB 保存なし）
- Propshaft（CSS）、Importmap（JS）

## ルーティング（DHH 流）

- 標準アクション以外が必要な場合は、専用コントローラを作成
  - `member`/`collection` ルートは使わない
  - 例：`Quiz::AnswersController`、`Quiz::QuestionsController`
- `resource` は単数シンボル → コントローラは常に複数形
  - `resource :quiz` → `QuizzesController`
  - `resource :answer` → `Quiz::AnswersController`
- `namespace` でサブコントローラをスコープ
  - `namespace :quiz` → `app/controllers/quiz/`
- ビューディレクトリはコントローラ名に従う（シンボルではない）
  - `Quiz::AnswersController` → `app/views/quiz/answers/`
- `controller: :quiz` のようなオーバーライドは不要

## ワークフロー

- コミットメッセージを提案し、承認を得てからコミットする
