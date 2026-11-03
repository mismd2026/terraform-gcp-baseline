# 必要な API を有効化する
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

module "network" {
  source = "./modules/network"

  name        = var.name
  region      = var.region
  subnet_cidr = var.subnet_cidr

  depends_on = [google_project_service.apis]
}

# ログ保管用の GCS バケット（公開禁止・均一アクセス・バージョニング・古いログの自動削除）
resource "random_id" "suffix" {
  byte_length = 3
}

resource "google_storage_bucket" "logs" {
  name                        = "${var.name}-logs-${random_id.suffix.hex}"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true # 学習用。本番では false にする

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
}

# Compute Engine の監査ログなどを GCS に書き出すログシンク
resource "google_logging_project_sink" "to_bucket" {
  name                   = "${var.name}-log-sink"
  destination            = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  filter                 = "resource.type=\"gce_subnetwork\" OR logName:\"cloudaudit.googleapis.com\""
  unique_writer_identity = true
}

# シンクの書き込み用サービスアカウントにだけ、バケットへの書き込みを許可する
resource "google_storage_bucket_iam_member" "sink_writer" {
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.to_bucket.writer_identity
}
