import { Controller } from "@hotwired/stimulus"

// タグ一覧を検索入力でリアルタイムフィルタリングする
export default class extends Controller {
  static targets = ["input", "list", "createButton"]

  // 入力値に一致するタグのみ表示し、非一致タグを非表示にする
  filter() {
    // list内の<label>を取得
    const query = this.inputTarget.value.toLowerCase()
    const labels = this.listTarget.querySelectorAll("label")

    labels.forEach(label => {
      const text = label.textContent.toLowerCase()
      label.style.display = text.includes(query) ? "" : "none"
    })

    // 作成ボタンの表示/非表示を切り替え
    this.updateCreateButton()
  }

  // 新しいタグを作成し、チェックボックスを追加する
  async create() {
    const name = this.inputTarget.value.trim()
    if (!name) return

    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    try {
      const response = await fetch("/tags.json", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ tag: { name } })
      })

      const data = await response.json()

      if (response.ok) {
        this.addTagCheckbox(data.id, data.name)
        this.inputTarget.value = ""
        this.filter()
      } else {
        alert(data.errors?.join("\n") || "タグの作成に失敗しました")
      }
    } catch (error) {
      alert("タグの作成に失敗しました")
    }
  }

  // 作成ボタンの表示/非表示を切り替える
  updateCreateButton() {
    const name = this.inputTarget.value.trim()
    const exists = this.isTagExists(name)

    if (this.hasCreateButtonTarget) {
      this.createButtonTarget.style.display = name && !exists ? "" : "none"
      this.createButtonTarget.textContent = `'${name}' を作成`
    }
  }

  // 指定名のタグが既に存在するか確認する
  isTagExists(name) {
    const labels = this.listTarget.querySelectorAll("label")
    return Array.from(labels).some(label =>
      label.textContent.toLowerCase() === name.toLowerCase()
    )
  }

  // 新しいタグのチェックボックスをリストに追加する
  addTagCheckbox(id, name) {
    const label = document.createElement("label")
    label.className = "tag-list__item"
    label.innerHTML = `<input type="checkbox" name="landmark[tag_ids][]" value="${id}" class="tag-list__checkbox" checked> ${name}`
    this.listTarget.appendChild(label)
  }
}
