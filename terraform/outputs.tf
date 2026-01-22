output "redmine_private_ips" {
  value = module.redmine.private_ips
}

output "db_private_ips" {
  value = module.database.private_ips
}
