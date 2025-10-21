######################
# Variáveis
######################

variable "zone_id" {}
variable "primary_lb_dns" {}
variable "secondary_lb_dns" {}
variable "lb_zone_id" {}

######################
# Registro DNS Primário
######################

resource "aws_route53_record" "failover_primary" {
  zone_id = var.zone_id
  name    = "app.example.com"  # Substitua pelo seu domínio
  type    = "A"

  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = var.primary_lb_dns
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

######################
# Registro DNS Secundário
######################

resource "aws_route53_record" "failover_secondary" {
  zone_id = var.zone_id
  name    = "app.example.com"  # Mesmo nome do primário
  type    = "A"

  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = var.secondary_lb_dns
    zone_id                = var.lb_zone_id
    evaluate_target_health = true
  }
}

