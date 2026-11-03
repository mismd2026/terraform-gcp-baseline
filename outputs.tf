output "network_name" {
  description = "作成した VPC ネットワーク名"
  value       = module.network.network_name
}

output "subnet_name" {
  description = "作成したサブネット名"
  value       = module.network.subnet_name
}

output "log_bucket" {
  description = "ログ保管用バケット名"
  value       = google_storage_bucket.logs.name
}
