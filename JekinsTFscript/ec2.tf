provider "aws" {
    region = "us-east-1"
    profile = "sule"
}

terraform {
    backend "s3" {
        bucket = "sulebucket"
        key    = "terraform.tfstate"
        region = "us-east-1"
    }
}


 resource "aws_default_vpc" "default_vpc" {
    tags = {
        Name = "default_vpc"
    }
   
 }

data "aws_availability_zones" "available" {}

    resource "aws_default_subnet" "subnet1" {
        availability_zone = data.aws_availability_zones.available.names[0]
        tags = {
            Name = "default subnet"
        }
    }
    

    resource "aws_security_group" "ec2secgroup" {
        name        = "ec2secgroup"
        description = "Allow SSH inbound traffic"
        vpc_id      = aws_default_vpc.default_vpc.id

        ingress {
            description      = "SSH from VPC"
            from_port        = 22
            to_port          = 22
            protocol         = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
            description      = "http"
            from_port        = 80
            to_port          = 80
            protocol         = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
            description      = "8080 protocol"
            from_port        = 8080
            to_port          = 8080
            protocol         = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }

        egress {
            from_port        = 0
            to_port          = 0
            protocol         = "-1"
            cidr_blocks      = ["0.0.0.0/0"]
        }
        tags = {
            Name = "ec2secgroup"
        }
    }
# data "aws_ami" "ubuntu" {
#             most_recent = true
#             owners      = ["099720109477"] # Canonical

#             filter {
#                 name   = "name"
#                 values = ["ubuntu/images/hvm-ssd/ubuntu-focal-24.04-amd64-server-*"]
#             }

#             filter {
#                 name   = "virtualization-type"
#                 values = ["hvm"]
#             }
#}

resource "aws_instance" "ec2instance" {
    ami           = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    subnet_id     = aws_default_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.ec2secgroup.id]
    key_name = "Devop"
    # Specify the user data script to run on instance launch
#    user_data = file("jenkins.sh")

    tags = {
        Name = "jenkinsserver"
    }

}

resource "null_resource" "name" {
    connection {
        type        = "ssh"
        host       = aws_instance.ec2instance.public_ip
        user       = "ubuntu"
        private_key = file("~/InfrastructureDeployment/jekinsTFscript/DevopKP.pem")
    }
    provisioner "file" {
        source      = "jenkins.sh"
        destination = "/tmp/jenkins.sh"
      
    }
  provisioner "remote-exec" {
        inline = [
            "chmod +x /tmp/jenkins.sh",
            "sudo /tmp/jenkins.sh"
        ]
    
  }
  depends_on = [aws_instance.ec2instance]
}

output "website_url" {
    value = join("", ["http://",aws_instance.ec2instance.public_dns, ":8080"])

}