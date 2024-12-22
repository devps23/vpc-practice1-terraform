output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "frontend_subnets" {
  value = aws_subnet.frontend_subnets.*.id
}
output "public_subnets" {
  value = aws_subnet.public_subnets.*.id
}
# output "backend_subnets" {
#   value = aws_subnet.backend.*.id
# }
# output "db_subnets" {
#   value = aws_subnet.db.*.id
# }