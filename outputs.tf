output "ip_us_east" {
  value = module.web_us_east.public_ip
}

output "ip_us_west" {
  value = module.web_us_west.public_ip
}
