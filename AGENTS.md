# AGENTS.md

## アーキテクチャ

- Rails 8.1 + Hotwire/Turbo（SPA ライクな体験）
- Quiz はセッションベース（DB 保存なし）
- Propshaft（CSS）、Importmap（JS）

## ルーティング（DHH 風）

- `resource` は単数シンボル → コントローラは常に複数形
  - `resource :quiz` → `QuizzesController`
  - `resource :answer` → `Quiz::AnswersController`
- `namespace` でサブコントローラをスコープ
  - `namespace :quiz` → `app/controllers/quiz/`
- ビューディレクトリはコントローラ名に従う（シンボルではない）
  - `Quiz::AnswersController` → `app/views/quiz/answers/`
- `controller: :quiz` のようなオーバーライドは不要
