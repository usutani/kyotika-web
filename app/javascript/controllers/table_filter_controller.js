import { Controller } from "@hotwired/stimulus"

// テーブル行を検索入力でリアルタイムフィルタリングする汎用コントローラ
export default class extends Controller {
  static targets = ["input", "list", "emptyMessage"]

  // 入力値に一致する行のみ表示し、非一致行を非表示にする
  filter() {
    const query = this.inputTarget.value.toLowerCase()
    const rows = this.listTarget.querySelectorAll("tr")
    let visibleCount = 0

    rows.forEach((row) => {
      const text = row.textContent.toLowerCase()
      const visible = text.includes(query)
      row.style.display = visible ? "" : "none"
      if (visible) visibleCount += 1
    })

    if (this.hasEmptyMessageTarget) {
      this.emptyMessageTarget.style.display = visibleCount === 0 ? "" : "none"
    }
  }
}
