resource "aws_vpc" "ntier" {
    cidr_block  = var.primary_network_cidr
    tags        = {
        Name    = "ntier primary"
    }
}

resource "aws_subnet" "subnets" {
    vpc_id      = aws_vpc.ntier.id
    count       = length(var.primary_subnets)
    cidr_block  = cidrsubnet(var.primary_network_cidr, 8, count.index)
    tags        = {
        Name    = var.primary_subnets[count.index]
    }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id      = aws_vpc.ntier.id
    tags        = {
        Name    = "ntier primary"
    }

    depends_on  = [
        aws_subnet.subnets
    ]

}

# public route table and private route table
resource "aws_route_table" "route_tables" {
    vpc_id          = aws_vpc.ntier.id
    count           = length(var.route_table_names)

    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.igw.id
    }

    tags        = {
        Name    =  var.route_table_names[count.index]
    }
}

