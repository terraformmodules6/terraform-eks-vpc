# Private subnet: for instances / internal lb
resource "aws_subnet" "private" {
  count             = "${length(var.private_subnet_ids) == 0 ? length(var.private_cidrs) : 0}"
  vpc_id            = "${coalesce(var.vpc_id, join("",aws_vpc.platform.*.id))}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  cidr_block        = "${element(var.private_cidrs, count.index)}"

  tags = "${merge(var.tags, map(
    "Name", "${var.platform_name}-private-${count.index}",
    "kubernetes.io/cluster/${var.platform_name}", "${var.platform_name}")
  )}"
}

resource "aws_nat_gateway" "private_gw" {
  count         = "${length(var.private_subnet_ids) == 0 && length(var.private_cidrs) != 0 ? 1 : 0}"
  allocation_id = "${aws_eip.private_gw[0].id}"
  subnet_id     = "${element(coalescelist(var.public_subnet_ids, aws_subnet.public.*.id), 0)}"

  tags = "${merge(var.tags, map(
    "Name", "${var.platform_name}-private-gw",
    "KubernetesCluster","${var.platform_name}",
    "kubernetes.io/cluster/${var.platform_name}", "${var.platform_name}")
  )}"
}

resource "aws_eip" "private_gw" {
  count = "${length(var.private_subnet_ids) == 0 && length(var.private_cidrs) != 0 ? 1 : 0}"
  vpc   = true

  tags = "${merge(var.tags, map(
    "Name", "${var.platform_name}-private-gw",
    "KubernetesCluster","${var.platform_name}")
  )}"
}

# Private route table: attach NAT gw for outbounds.
resource "aws_route_table" "private" {
  count  = "${length(var.private_subnet_ids) == 0 && length(var.private_cidrs) != 0 ? 1 : 0}"
  vpc_id = "${coalesce(var.vpc_id, join("",aws_vpc.platform.*.id))}"

  tags = "${merge(var.tags, map(
    "Name", "${var.platform_name}-private-rt",
    "kubernetes.io/cluster/${var.platform_name}", "${var.platform_name}")
  )}"
}

resource "aws_route" "private_internet" {
  count                  = "${length(var.private_subnet_ids) == 0 && length(var.private_cidrs) != 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.private[0].id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.private_gw[0].id}"
  depends_on             = ["aws_route_table.private"]
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnet_ids) == 0 && length(var.private_cidrs) != 0 ? length(var.private_cidrs) : 0}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private[0].id}"
}
