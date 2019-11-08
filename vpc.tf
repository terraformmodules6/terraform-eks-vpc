data "aws_availability_zones" "available" {}

resource "aws_vpc" "platform" {
  count                = "${var.vpc_id != "" ? 0 : 1}"
  cidr_block           = "${var.platform_cidr}"
  enable_dns_hostnames = true

  tags = "${merge(var.tags, map(
    "Name", "${var.platform_name}",
    "kubernetes.io/cluster/${var.platform_name}", "${var.platform_name}")
  )}"
}
