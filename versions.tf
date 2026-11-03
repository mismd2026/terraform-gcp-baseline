terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # チームで使う場合は state を GCS に置く。最初はローカル state で試し、
  # 作成した state 用バケット名を入れてからコメントを外して `terraform init -migrate-state` する。
  # backend "gcs" {
  #   bucket = "<state用バケット名>"
  #   prefix = "baseline"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region

  default_labels = {
    managed-by = "terraform"
  }
}
