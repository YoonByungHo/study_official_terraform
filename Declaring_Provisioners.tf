# How to use Provisioners


# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# # 생성된 EC2에서 local-exec가 실행됨
# resource "aws_instance" "server" {

#   ami           = data.aws_ami.example.id
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Server"
#   }
#   lifecycle {
#     precondition {
#         condition     = data.aws_ami.example.architecture == "x86_64"
#         error_message = "The selected AMI must be for the x86_64 architecture."
#     }
#   }
#   provisioner "local-exec" {
#     command = "echo The servers IP address is ${self.private_ip} >> ~/test.txt"
#   }
# }

# # Destroy-Time Provisioners
# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# # 삭제될 때 EC2에서 local-exec가 실행됨
# resource "aws_instance" "server" {

#   ami           = data.aws_ami.example.id
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Server"
#   }
#   lifecycle {
#     precondition {
#         condition     = data.aws_ami.example.architecture == "x86_64"
#         error_message = "The selected AMI must be for the x86_64 architecture."
#     }
#   }
#   provisioner "local-exec" {
#     when = destroy
#     command = "echo The servers IP address is ${self.private_ip}"
#   }
# }

# Failure Behavior

# 
# resource "aws_instance" "server" {

#   ami           = data.aws_ami.example.id
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Server"
#   }
#   lifecycle {
#     precondition {
#         condition     = data.aws_ami.example.architecture == "x86_64"
#         error_message = "The selected AMI must be for the x86_64 architecture."
#     }
#   }
#   provisioner "local-exec" {
#     on_failure = fail
#     command = "echo The servers IP address is ${self.private_ip}"
#   }
# }