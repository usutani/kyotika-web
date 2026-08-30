import { Controller } from "@hotwired/stimulus"

// タグ一覧を検索入力でリアルタイムフィルタリングする
export default class extends Controller {
  static targets = ["input", "list"]

  // 入力値に一致するタグのみ表示し、非一致タグを非表示にする
  filter() {
    // list内の<label>を取得
    const query = this.inputTarget.value.toLowerCase()
    const labels = this.listTarget.querySelectorAll("label")

    labels.forEach(label => {
      const text = label.textContent.toLowerCase()
      label.style.display = text.includes(query) ? "" : "none"
    })
  }
}
