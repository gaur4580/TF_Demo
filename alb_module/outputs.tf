output "alb_arn" {
  value       = aws_lb.alb.arn
  description = "alb arn"
}
output tg_arn {
  value = aws_lb_target_group.tg.arn
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "alb dns name"
}
output "alb_zone_id" {
  value       = aws_lb.alb.zone_id
  description = "alb zone id"
}