# カスタムモードの VPC とサブネット。
# 外部 IP を持たない VM でも外に出られるよう Cloud NAT を置き、
# SSH は IAP（Identity-Aware Proxy）経由のみに限定する（ゼロトラスト型の入口）。

resource "google_compute_network" "this" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name                     = "${var.name}-subnet"
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "this" {
  name    = "${var.name}-router"
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.name}-nat"
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# IAP の送信元レンジからの SSH のみ許可する
resource "google_compute_firewall" "allow_iap_ssh" {
  name      = "${var.name}-allow-iap-ssh"
  network   = google_compute_network.this.id
  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# それ以外の受信はすべて拒否（明示的なデフォルト拒否）
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "${var.name}-deny-all-ingress"
  network   = google_compute_network.this.id
  direction = "INGRESS"
  priority  = 65000

  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }
}
