output "alb_arn" {
  description = "ARN of ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS Name of ALB"
  value       = aws_lb.this.dns_name
}

output "blue_tg_arn" {
  description = "Blue Target Group ARN"
  value       = aws_lb_target_group.blue.arn
}

output "green_tg_arn" {
  description = "Green Target Group ARN"
  value       = aws_lb_target_group.green.arn
}

output "production_listener_arn" {
  description = "Production Listener ARN"
  value       = aws_lb_listener.production.arn
}

output "test_listener_arn" {
  description = "Test Listener ARN"
  value       = aws_lb_listener.test.arn
}

output "alb_security_group_id" {
  description = "Security group ID of ALB"
  value       = aws_security_group.alb.id
}

output "blue_tg_name" {
  description = "Name of Blue Target Group"
  value       = aws_lb_target_group.blue.name
}

output "green_tg_name" {
  description = "Name of Green Target Group"
  value       = aws_lb_target_group.green.name
}

