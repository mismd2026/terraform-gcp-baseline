variable "project_id" {
  description = "使用する GCP プロジェクト ID（terraform.tfvars で指定する）"
  type        = string
}

variable "name" {
  description = "リソース名の接頭辞"
  type        = string
  default     = "baseline"
}

variable "region" {
  description = "GCP リージョン"
  type        = string
  default     = "asia-northeast1"
}

variable "subnet_cidr" {
  description = "サブネットの CIDR"
  type        = string
  default     = "10.10.0.0/20"
}
