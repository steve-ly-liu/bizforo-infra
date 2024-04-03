#-------- vpc/outputs.tf --------
#=================================
output "bf_public_subnets" {
    value = aws_subnet.bf_public_subnet.id
}

output "bf_public_sg" {
  value = aws_security_group.bf_public_sg
}

output "bf_subnet_ips" {
    value = aws_subnet.bf_public_subnet.cidr_block
}