# Public subnet: for router LB
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_ids) == 0 ? length(var.public_cidrs) : 0
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  vpc_id            = coalesce(var.vpc_id,join("",aws_vpc.platform.*.id))
  cidr_block        = element(var.public_cidrs, count.index)

  tags = merge(var.tags, map(
    "Name", "${var.platform_name}-public-${count.index}",
    "kubernetes.io/cluster/${var.platform_name}", var.platform_name)
  )
}

# Public access to the router
resource "aws_internet_gateway" "public_gw" {
  count  = length(var.public_subnet_ids) == 0 && length(var.public_cidrs) != 0 ? 1 : 0
  vpc_id = coalesce(var.vpc_id,join("",aws_vpc.platform.*.id))

  tags = merge(var.tags, map(
    "Name", "${var.platform_name}-public-gw",
    "KubernetesCluster", var.platform_name,
    "kubernetes.io/cluster/${var.platform_name}", var.platform_name)
  )
}

# Public route table: attach Internet gw for internet access.

resource "aws_route_table" "public" {
  count  = length(var.public_subnet_ids) == 0 && length(var.public_cidrs) != 0 ? 1 : 0
  vpc_id = coalesce(var.vpc_id,join("",aws_vpc.platform.*.id))

  tags = merge(var.tags, map(
    "Name", "${var.platform_name}-public-rt",
    "kubernetes.io/cluster/${var.platform_name}", var.platform_name)
  )
}

resource "aws_route" "public_internet" {
  count                  = length(var.public_subnet_ids) == 0 && length(var.public_cidrs) != 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public_gw[0].id
  depends_on             = ["aws_route_table.public"]
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids) == 0 && length(var.public_cidrs) != 0 ? length(var.public_cidrs) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}
