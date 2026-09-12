import { Controller } from "@hotwired/stimulus"

// 地域セレクトに応じて問題数の上限・表示件数を更新する
export default class extends Controller {
  static targets = ["region", "count", "total"]
  static values = { counts: Object, all: Number }

  update() {
    const regionId = this.regionTarget.value
    const total = regionId ? (this.countsValue[regionId] || 0) : this.allValue

    if (this.hasCountTarget) {
      this.countTarget.max = Math.max(total, 1)
      const current = parseInt(this.countTarget.value, 10) || 1
      this.countTarget.value = Math.min(Math.max(current, 1), Math.max(total, 1))
    }

    if (this.hasTotalTarget) {
      this.totalTarget.textContent = ` / ${total}問`
    }
  }
}
