#data "aws_vpc" "selected" {
#    id = var.vpc_id
#}

output "vpc_id" {
    description = "VPC id"
    value = aws_vpc.main.id
}

output "subnet_id" {
    description = "Subnet ids"
    //for_each = aws_subnet.subnet[*]
        value = aws_subnet.subnet[*].id
}

//output "subnet_id_2" {
//    description = "Subnet ids"
//    value = aws_subnet.subnet2.id
//}

output "availability_zone" {
    description = "Availability zones"
    //for_each = aws_subnet.subnet[*]
        value = aws_subnet.subnet[*].availability_zone
}

output "aws_instance_public_ip" {
    description = "Public IP"
    //for_each = aws_subnet.subnet[*]
        value = aws_instance.web.public_ip
}


//output "availability_zone_2" {
//    description = "Availability zones"
//    value = aws_subnet.subnet2.availability_zone
//}