import { Controller } from "@hotwired/stimulus"

// タブボタンでペインを切り替える
export default class extends Controller {
  static targets = ["tab", "pane"]

  // 押下されたタブに対応するペインのみ表示する
  switch(event) {
    const name = event.currentTarget.dataset.paneName

    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.paneName === name
      tab.classList.toggle("quiz__tab--active", active)
      tab.setAttribute("aria-selected", active.toString())
    })

    this.paneTargets.forEach((pane) => {
      pane.hidden = pane.dataset.paneName !== name
    })
  }
}
