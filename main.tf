resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "allow_tls" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "allow_tls"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
    security_group_id = aws_security_group.allow_tls.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
    security_group_id = aws_security_group.allow_tls.id
    cidr_ipv4         = "0.0.0.0/0"
    ip_protocol       = "-1"
}

resource "aws_subnet" "Public_Subnet" {
    vpc_id = aws_vpc.main.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.1.0/24"

    tags = {
        Name = "Public_Subnet"
    }
}

resource "aws_instance" "EC2-Instance" {
    ami = "ami-05ffe3c48a9991133"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.Public_Subnet.id
    associate_public_ip_address = "true"
    vpc_security_group_ids = [aws_security_group.allow_tls.id]
    tags = {
        Name = "Alone-Instance"
    }
}

output "ec2_public" {
    value = aws_instance.EC2-Instance.public_ip
    depends_on = [ aws_vpc_security_group_ingress_rule.allow_tls_ipv4 ]
}