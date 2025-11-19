output "office-hours-lb-dns" {
  value = "http://${aws_lb.alb-from-terraform.dns_name}"
}