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

## CSS

- BEM 命名規則（`block__element--modifier`）
  - 修飾子は `--` 区切り（例: `.btn--primary`, `.data-table__cell--num`）
  - 要素は `__` 区切り（例: `.page-header__title`, `.quiz__progress-bar`）
- コンポーネントごとにファイル分割
  - `app/assets/stylesheets/` 配下に配置
  - `application.css` は `@import` マニフェストのみ
- CSS カスタムプロパティは `base.css` に定義
  - 色: `--color-primary`, `--color-ink`, `--color-canvas` 等
  - 间距: `--space-sm`, `--space-md`, `--space-lg` 等
  - フォント: `--text-sm`, `--text-base`, `--text-lg` 等
- Fizzy (https://github.com/basecamp/fizzy) を参考にする
- Propshaft を使用（事前処理なし）

## ワークフロー

- コミットメッセージを提案し、承認を得てからコミットする
- 実装時は `bin/rubocop` が成功することを確認する
