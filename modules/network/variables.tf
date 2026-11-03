variable "name" {
  description = "リソース名の接頭辞"
  type        = string
}

variable "region" {
  description = "リージョン"
  type        = string
}

variable "subnet_cidr" {
  description = "サブネットの CIDR"
  type        = string
}
