output "platform_vpc_id" {
  value = "${coalesce(var.vpc_id, join("",aws_vpc.platform.*.id))}"
}

output "public_subnet_ids" {
  value = ["${coalescelist(var.public_subnet_ids, aws_subnet.public.*.id)}"]
}

output "private_subnet_ids" {
  value = ["${coalescelist(var.private_subnet_ids, aws_subnet.private.*.id)}"]
}

output "nat_gateway_public_ip" {
  value = "${aws_eip.private_gw.*.public_ip}"
}
