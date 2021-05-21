output "natgw_ids" {
  value = aws_nat_gateway.natgw.*.id
}
