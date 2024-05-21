output "public_ec2_ips" {
  value = aws_instance.public[*].public_ip
}
output "public_ec2_ids" {
  value = aws_instance.public[*].id
}
output "private_ec2_ips" {
  value = aws_instance.private[*].public_ip
}
output "private_ec2_ids" {
  value = aws_instance.private[*].id
}