resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "aws_vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "NAME-public"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet" {
  count=2
  vpc_id     = aws_vpc.main.id
  #cidr_block = "10.0.1.0/24"
  cidr_block = cidrsubnet("10.0.1.0/24",2,count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "NAME-public-${count.index}"
  }
}

//count: [<subnet0>, <subnet1>]
//for_each: {us-east1a: subnet0, us-east1b: subnet1}

//resource "aws_subnet" "subnet2" {
//  vpc_id     = aws_vpc.main.id
//  cidr_block = cidrsubnet("10.0.2.0/24",2,count.index)
//  #cidr_block = "10.0.2.0/24"
//  availability_zone = data.aws_availability_zones.available.names[count.index]

//  tags = {
//    Name = "NAME-public-${count.index}"
//  }
//}

//data "aws_subnet" "subnet" {
//  state = "available"
//}

resource "aws_route_table_association" "a" {
    count=length(aws_subnet.subnet.*.id)
  //for_each = toset(aws_subnet.subnet.*.id)
    //subnet_id      = each.value
    subnet_id      = element(aws_subnet.subnet.*.id, count.index)
    route_table_id = aws_route_table.rt.id
}

data "local_file" "private_key" {
    filename = "/users/kostiao/.ssh/id_rsa"
}

data "local_file" "public_key" {
    filename = "/users/kostiao/.ssh/id_rsa.pub"
}


resource "aws_key_pair" "server_key" {
  key_name = "key_name_prefix"
  public_key = file(data.local_file.public_key.filename)
}

resource "aws_security_group" "instance" {
  name_prefix = "security_group"
  description = "AWS security group"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_ssh" {
  security_group_id = "${aws_security_group.instance.id}"
  type = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
 //cidr_blocks      = [aws_vpc.main.cidr_block] 
}

resource "aws_security_group_rule" "allow_http" {
  security_group_id = "${aws_security_group.instance.id}"
  type = "ingress" 
  from_port        = 80
  to_port          = 80
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  //cidr_blocks      = [aws_vpc.main.cidr_block] 
}

resource "aws_security_group_rule" "instance_out_all" {
  security_group_id = "${aws_security_group.instance.id}"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


data "aws_ami" "example" {
  most_recent = true

  filter {
    //name   = ["amzn2-ami-hvm-2.0*"]
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }
 
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.example.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]    
  subnet_id = aws_subnet.subnet[0].id
  key_name = aws_key_pair.server_key.key_name

  provisioner "file" {
    source      = "../scripts/install_docker_ec2.sh"
    destination = "/var/tmp/install_docker_ec2.sh"
    #destination    = "../scripts/install_docker_ec2.sh"
    #destination = "/Users/kostiao/Documents/DevOps bootcamp/kittens-store/ops/scripts/install_docker_ec2.sh"
  
  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = "${aws_instance.web.public_ip}"
    private_key = file(data.local_file.private_key.filename)
            } 
  }

  provisioner "remote-exec" {
  inline = [
    "chmod +x /var/tmp/install_docker_ec2.sh",
    "/var/tmp/install_docker_ec2.sh",
    ]

    connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = "${aws_instance.web.public_ip}"
    private_key = file(data.local_file.private_key.filename)
            }
}

}


provider "aws" {
  region  = "us-east-2"
}


