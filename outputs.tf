output "jenkins-url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}
output "prometheus-url" {
  value = "http://${aws_instance.monitoring.public_ip}:9090"
}
output "grafana-url" {
  value = "http://${aws_instance.monitoring.public_ip}:3000"
}