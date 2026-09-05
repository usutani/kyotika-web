import { Controller } from "@hotwired/stimulus"
import "leaflet"

const L = window.L

// 地図探索クイズ: クリック地点へ犬を移動し、近傍のきらめきでクイズを開く
// 犬は画面中央固定オーバーレイ。クリック地点へ panTo することで犬が中央に来る。
export default class extends Controller {
  static targets = ["canvas", "dog", "status", "modal", "frame"]
  static values = {
    spots: Array,
    foundIds: Array,
    center: Array,
    zoom: Number,
    questionUrl: String
  }

  // 近傍とみなす半径 (メートル)
  static NEARBY_RADIUS_M = 300

  connect() {
    this.currentSpotId = null
    this.markers = new Map()
    this.found = new Set(this.foundIdsValue)

    this.map = L.map(this.canvasTarget, { zoomControl: true }).setView(this.centerValue, this.zoomValue)
    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)

    this.renderMarkers()
    this.updateStatus()

    this.map.on("click", (e) => this.moveDog(e.latlng))
    this.map.on("movestart", () => this.dogTarget.classList.add("map-quiz__dog--moving"))
    this.map.on("moveend", () => {
      this.dogTarget.classList.remove("map-quiz__dog--moving")
      this.checkNearby()
    })

    this.observer = new MutationObserver(() => this.watchForDiscovery())
    this.observer.observe(this.modalTarget, { childList: true, subtree: true })

    // 初期位置の近傍チェック
    this.checkNearby()
  }

  disconnect() {
    this.observer?.disconnect()
    this.map?.remove()
  }

  // クリック地点へ地図をスクロールし、犬 (中央) を移動させる
  moveDog(latlng) {
    this.map.panTo(latlng, { animate: true })
  }

  renderMarkers() {
    for (const spot of this.spotsValue) {
      if (this.markers.has(spot.id)) continue
      const marker = this.found.has(spot.id) ? this.buildFoundMarker(spot) : this.buildSparkleMarker(spot)
      marker.addTo(this.map)
      this.markers.set(spot.id, marker)
    }
  }

  buildSparkleMarker(spot) {
    return L.marker([spot.latitude, spot.longitude], {
      icon: L.divIcon({ className: "map-quiz__sparkle", html: '<span class="map-quiz__sparkle-inner">✨</span>', iconSize: [24, 24], iconAnchor: [12, 12] }),
      interactive: false,
      keyboard: false
    })
  }

  buildFoundMarker(spot) {
    return L.marker([spot.latitude, spot.longitude], {
      icon: L.divIcon({ className: "map-quiz__found", html: "📍", iconSize: [24, 24], iconAnchor: [12, 24] }),
      keyboard: false
    })
  }

  // 犬 (地図中央) の近傍に未発見スポットがあればクイズを開く
  checkNearby() {
    const center = this.map.getCenter()
    const near = this.spotsValue
      .filter((spot) => !this.found.has(spot.id))
      .map((spot) => ({ spot, dist: center.distanceTo([spot.latitude, spot.longitude]) }))
      .filter(({ dist }) => dist <= this.constructor.NEARBY_RADIUS_M)
      .sort((a, b) => a.dist - b.dist)[0]

    if (near) {
      this.openQuiz(near.spot)
    } else {
      this.currentSpotId = null
      this.modalTarget.hidden = true
      this.updateStatus("このあたりに思い出はなさそうだ…きらめき✨を探して移動しよう。")
    }
  }

  openQuiz(spot) {
    this.modalTarget.hidden = false
    this.updateStatus("きらめきの近くに来た！思い出のクイズが開いた。")
    if (this.currentSpotId !== spot.id) {
      this.currentSpotId = spot.id
      this.frameTarget.src = `${this.questionUrlValue}?landmark_id=${spot.id}`
    }
  }

  // 回答結果の Turbo Stream に発見通知があればマーカーを更新する
  watchForDiscovery() {
    const found = this.modalTarget.querySelector("[data-map-quiz-found-id]")
    if (!found) return
    const id = Number(found.dataset.mapQuizFoundId)
    if (this.found.has(id)) return
    this.found.add(id)
    const spot = this.spotsValue.find((s) => s.id === id)
    const old = this.markers.get(id)
    if (old) this.map.removeLayer(old)
    if (spot) {
      const marker = this.buildFoundMarker(spot)
      marker.addTo(this.map)
      this.markers.set(id, marker)
    }
    this.updateStatus()
    // 発見後はモーダルを残し、次の移動で近傍チェックが走る
    this.currentSpotId = null
  }

  updateStatus(message) {
    if (message) {
      this.statusTarget.textContent = message
      return
    }
    this.statusTarget.textContent = `発見 ${this.found.size} / ${this.spotsValue.length}`
  }
}
