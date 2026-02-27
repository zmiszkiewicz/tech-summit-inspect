output "client_public_ip" {
  description = "Public IP for Windows client VM (RDP access)"
  value       = aws_eip.client_eip.public_ip
}
