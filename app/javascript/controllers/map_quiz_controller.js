import { Controller } from "@hotwired/stimulus"
import "leaflet"

const L = window.L

// 地図探索クイズ: クリック地点へ犬を移動し、近傍のきらめきでクイズを開く
// 犬は画面中央固定オーバーレイ。クリック地点へ panTo することで犬が中央に来る。
export default class extends Controller {
  static targets = ["canvas", "dog", "status", "modal", "frame", "toast"]
  static values = {
    spots: Array,
    foundIds: Array,
    hiddenIds: Array,
    center: Array,
    zoom: Number,
    fitBounds: Boolean,
    resume: Boolean,
    questionUrl: String
  }

  // sessionStorage に保存する直前表示のキー
  static VIEW_STORAGE_KEY = "map-quiz-view"

  // 近傍とみなす半径 (メートル)
  static NEARBY_RADIUS_M = 300

  // 画面に表示する文言集
  static MESSAGES = {
    nothingNearby: "このあたりに思い出はなさそうだ…きらめき✨を探して移動しよう。",
    quizOpened: "きらめきの近くに来た！思い出のクイズが開いた。",
    revealedAll: "すべてのきらめきが見えるようになった！"
  }

  // マーカーの基準サイズ (ピクセル)。iconAnchor はここから派生させる。
  static MARKER_SIZE = 32

  // トーストの表示時間 (ミリ秒)
  static TOAST_VISIBLE_MS = 4000

  connect() {
    this.currentSpotId = null
    this.markers = new Map()
    this.found = new Set(this.foundIdsValue)
    this.hidden = new Set(this.hiddenIdsValue)

    this.setupMap()
    this.renderMarkers()
    this.updateStatus()
    this.bindMapEvents()
    this.observeModal()

    // 初期位置の近傍チェック
    this.checkNearby()
  }

  // 地図を生成し直前の表示または全体表示を適用する
  // ズーム操作で中心 (犬の位置) がずれないよう、全て中心基準に固定する
  setupMap() {
    this.map = L.map(this.canvasTarget, {
      zoomControl: true,
      scrollWheelZoom: "center",
      doubleClickZoom: "center",
      touchZoom: "center",
      boxZoom: false
    }).setView(this.centerValue, this.zoomValue)
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)

    if (!this.restoreView()) {
      this.fitSpotsBounds()
    }
  }

  // 地図操作と犬の動作・表示保存・近傍チェックを結びつける
  bindMapEvents() {
    this.map.on("click", (e) => this.moveDog(e.latlng))
    this.map.on("movestart", () => this.dogTarget.classList.add("map-quiz__dog--moving"))
    this.map.on("moveend", () => {
      this.dogTarget.classList.remove("map-quiz__dog--moving")
      this.saveView()
      this.checkNearby()
    })
    this.map.on("zoomend", () => this.saveView())
  }

  // モーダル内の Turbo Stream 合図を監視する
  observeModal() {
    this.observer = new MutationObserver(() => this.watchForDiscovery())
    this.observer.observe(this.modalTarget, { childList: true, subtree: true })

    // クイズ内容の読み込み完了後に回答欄へスクロールする
    this.frameTarget.addEventListener("turbo:frame-load", () => {
      this.modalTarget.scrollIntoView({ behavior: "smooth", block: "nearest" })
    })
  }

  disconnect() {
    clearTimeout(this.toastTimer)
    this.observer?.disconnect()
    this.map?.remove()
  }

  // クリック地点へ地図をスクロールし、犬 (中央) を移動させる
  moveDog(latlng) {
    this.map.panTo(latlng, { animate: true })
  }

  // 対象スポット全体が収まるよう表示範囲を調整する (発見記録からの遷移時は対象外)
  fitSpotsBounds() {
    if (!this.fitBoundsValue || this.spotsValue.length === 0) return
    const bounds = L.latLngBounds(this.spotsValue.map((spot) => [spot.latitude, spot.longitude]))
    this.map.fitBounds(bounds, { padding: [30, 30], maxZoom: 15 })
  }

  // 発見記録から戻った際は直前の表示を復元する (保存なし・通常時は対象外)
  // 復元した場合は true を返す
  restoreView() {
    if (!this.resumeValue) return false
    let saved = null
    try {
      saved = JSON.parse(sessionStorage.getItem(this.constructor.VIEW_STORAGE_KEY))
    } catch {
      saved = null
    }
    if (!saved || !Array.isArray(saved.center) || typeof saved.zoom !== "number") return false
    this.map.setView(saved.center, saved.zoom, { animate: false })
    return true
  }

  // 現在の表示を保存する
  saveView() {
    const center = this.map.getCenter()
    try {
      sessionStorage.setItem(
        this.constructor.VIEW_STORAGE_KEY,
        JSON.stringify({ center: [center.lat, center.lng], zoom: this.map.getZoom() })
      )
    } catch {
      // 保存失敗時は何もしない (プライベートモード等)
    }
  }

  renderMarkers() {
    for (const spot of this.spotsValue) {
      if (this.markers.has(spot.id)) continue
      if (this.hidden.has(spot.id)) continue
      this.placeMarker(spot, this.found.has(spot.id) ? this.buildFoundMarker(spot) : this.buildSparkleMarker(spot))
    }
  }

  // マーカーを地図へ配置し旧表示と差し替える
  placeMarker(spot, marker) {
    const old = this.markers.get(spot.id)
    if (old) this.map.removeLayer(old)
    marker.addTo(this.map)
    this.markers.set(spot.id, marker)
  }

  buildSparkleMarker(spot) {
    const size = this.constructor.MARKER_SIZE
    return this.buildMarker(spot, {
      className: "map-quiz__sparkle",
      html: '<span class="map-quiz__sparkle-inner">✨</span>',
      iconSize: [size, size],
      iconAnchor: [size / 2, size / 2],
      interactive: false
    })
  }

  buildFoundMarker(spot) {
    const size = this.constructor.MARKER_SIZE
    return this.buildMarker(spot, {
      className: "map-quiz__found",
      html: "📍",
      iconSize: [size, size],
      iconAnchor: [size / 2, size]
    })
  }

  buildMarker(spot, { className, html, iconSize, iconAnchor, interactive = true }) {
    return L.marker([spot.latitude, spot.longitude], {
      icon: L.divIcon({ className, html, iconSize, iconAnchor }),
      interactive,
      keyboard: false
    })
  }

  // 犬 (地図中央) の近傍にある表示中の未発見スポットがあればクイズを開く
  checkNearby() {
    const near = this.nearestVisibleUndiscoveredSpot(this.map.getCenter())

    if (near) {
      this.openQuiz(near)
    } else {
      this.currentSpotId = null
      this.modalTarget.hidden = true
      this.updateStatus(this.constructor.MESSAGES.nothingNearby)
    }
  }

  // 表示中の未発見スポットの中で地図中央に最も近いものを返す (なければ null)
  nearestVisibleUndiscoveredSpot(center) {
    return this.spotsWithDistance(center)
      .filter(({ spot }) => !this.found.has(spot.id) && !this.hidden.has(spot.id))
      .filter(({ dist }) => dist <= this.constructor.NEARBY_RADIUS_M)
      .sort((a, b) => a.dist - b.dist)
      .map(({ spot }) => spot)[0] ?? null
  }

  // 全スポットと地図中央からの距離の一覧
  spotsWithDistance(center) {
    return this.spotsValue.map((spot) => ({
      spot,
      dist: center.distanceTo([spot.latitude, spot.longitude])
    }))
  }

  openQuiz(spot) {
    this.modalTarget.hidden = false
    this.updateStatus(this.constructor.MESSAGES.quizOpened)
    if (this.currentSpotId !== spot.id) {
      this.currentSpotId = spot.id
      this.frameTarget.src = `${this.questionUrlValue}?landmark_id=${spot.id}`
    }
  }

  // 回答結果の Turbo Stream に発見通知があればマーカーを更新する
  watchForDiscovery() {
    this.watchForReveal()
    this.watchForToast()
    const found = this.modalTarget.querySelector("[data-map-quiz-found-id]")
    if (!found) return
    this.applyDiscovery(Number(found.dataset.mapQuizFoundId))
  }

  // 発見を記録しマーカーを📍へ置換する
  applyDiscovery(id) {
    if (this.found.has(id)) return
    this.found.add(id)
    const spot = this.spotsValue.find((s) => s.id === id)
    if (spot) this.placeMarker(spot, this.buildFoundMarker(spot))
    this.updateStatus()
    // 発見後はモーダルを残し、次の移動で近傍チェックが走る
    this.currentSpotId = null
  }

  // 全表示の合図があれば隠しマーカーを出現させトーストで通知する
  watchForReveal() {
    const signal = this.modalTarget.querySelector("[data-map-quiz-reveal-all]")
    if (!signal || this.hidden.size === 0) return
    signal.remove()
    for (const spot of this.spotsValue) {
      if (!this.hidden.has(spot.id) || this.found.has(spot.id)) continue
      this.placeMarker(spot, this.buildSparkleMarker(spot))
    }
    this.hidden.clear()
    this.showToast(this.constructor.MESSAGES.revealedAll)
    this.updateStatus(this.constructor.MESSAGES.revealedAll)
  }

  // 汎用トーストの合図があれば通知する (表示後は除去し再表示を防ぐ)
  watchForToast() {
    const signal = this.modalTarget.querySelector("[data-map-quiz-toast]")
    if (!signal) return
    const message = signal.dataset.mapQuizToast
    signal.remove()
    if (!message) return
    this.showToast(message)
    this.updateStatus(message)
  }

  showToast(message) {
    clearTimeout(this.toastTimer)
    this.toastTarget.textContent = message
    this.toastTarget.hidden = false
    this.toastTimer = setTimeout(() => { this.toastTarget.hidden = true }, this.constructor.TOAST_VISIBLE_MS)
  }

  updateStatus(message) {
    if (message) {
      this.statusTarget.textContent = message
      return
    }
    this.statusTarget.textContent = `発見 ${this.found.size} / ${this.spotsValue.length}`
  }
}
