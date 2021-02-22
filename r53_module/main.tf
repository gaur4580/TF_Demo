resource "aws_route53_zone" "private" {
  name = var.r53_zone_name
  force_destroy = true

  dynamic vpc {
  	for_each = var.is_public_zone ? [] : [1]
    content {
      vpc_id     = var.vpc_id
    }
}
}

resource "aws_route53_record" "this" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}