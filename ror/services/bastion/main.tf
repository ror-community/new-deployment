# delete after testing new bastion host
# ssh key generated manually in AWS console
resource "aws_instance" "bastion" {
    ami = var.ami["eu-west-1"]
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.bastion.id]
    subnet_id = data.aws_subnet.public_subnet.id
    key_name = var.key_name
    associate_public_ip_address = "true"
    user_data = data.template_file.bastion-user-data-cfg.rendered
    tags = {
        Name = "Bastion"
    }
}

resource "aws_eip" "bastion" {
  vpc = "true"
}

resource "aws_eip_association" "bastion" {
  instance_id = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

resource "aws_route53_record" "bastion" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "${var.hostname}.ror.org"
    type = "A"
    ttl = var.ttl
    records = [aws_eip.bastion.public_ip]
}

resource "aws_route53_record" "split-bastion" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "${var.hostname}.ror.org"
    type = "A"
    ttl = var.ttl
    records = [aws_instance.bastion.private_ip]
}

resource "aws_security_group" "bastion" {
    name = "bastion"
    description = "Managed by Terraform"
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "bastion"
    }
}

resource "aws_instance" "bastion-2023" {
    ami = var.ami_linux_2023["eu-west-1"]
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.bastion.id]
    subnet_id = data.aws_subnet.public_subnet.id
    key_name = var.key_name_linux_2023
    associate_public_ip_address = "true"
    user_data = data.template_file.bastion-2023-user-data-cfg.rendered
    tags = {
        Name = "Bastion 2023"
    }
}

resource "aws_eip" "bastion-2023" {
  vpc = "true"
}

resource "aws_eip_association" "bastion-2023" {
  instance_id = aws_instance.bastion-2023.id
  allocation_id = aws_eip.bastion-2023.id
}

resource "aws_route53_record" "bastion-2023" {
    zone_id = data.aws_route53_zone.public.zone_id
    name = "${var.hostname_linux_2023}.ror.org"
    type = "A"
    ttl = var.ttl
    records = [aws_eip.bastion-2023.public_ip]
}

resource "aws_route53_record" "split-bastion-2023" {
    zone_id = data.aws_route53_zone.internal.zone_id
    name = "${var.hostname_linux_2023}.ror.org"
    type = "A"
    ttl = var.ttl
    records = [aws_instance.bastion-2023.private_ip]
}
