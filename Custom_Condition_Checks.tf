# Custom Condition Checks
# 수명 주기 블록과 함께 사전 조건 및 사후 조건 블록을 추가하여 리소스 및 데이터 원본이 작동하는 방식에 대한 가정 및 보장을 지정할 수 있습니다. 
# 다음 예제에서는 AMI가 올바르게 구성되었는지 확인하는 사전 조건을 생성합니다.

# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# 프리컨디션 조건에 걸려서 생성되지 않고 error_message를 뱉음
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
# }

# 포스트 조건에 걸려서 생성되지 않고 error_message를 뱉음
# resource "aws_instance" "server" {

#   ami           = data.aws_ami.example.id
#   instance_type = "t2.micro"

#   tags = {
#     "Component" = "nomad-server11"
#   }
#   lifecycle {
#     postcondition {
#       condition     = self.tags["Component"] == "nomad-server"
#       error_message = "tags[\"Component\"] must be \"nomad-server\"."
#     }
#   }
# }

#post, pre 조건의 차이가 명확히 뭐지?
#pre는 생성 전에 알 수 있는 정보로 조건을 걸 수 있음
#post는 생성 후에 알 수 있는 정보들(tag, 암호화 여부)로 조건을 걸 수 있음


## example
# resource "aws_instance" "example" {
#   instance_type = "t2.micro"
#   ami           = data.aws_ami.example.id

#   lifecycle {
#     precondition {
#       condition     = data.aws_ami.example.architecture == "x86_64"
#       error_message = "The selected AMI must be for the x86_64 architecture."
#     }

#     # The EC2 instance must be allocated a public DNS hostname.
#     postcondition {
#       condition     = self.public_dns != ""
#       error_message = "EC2 instance must be in a VPC that has public DNS hostnames enabled."
#     }
#   }
# }

# data "aws_ebs_volume" "example" {
#   filter {
#     name = "volume-id"
#     values = [aws_instance.example.root_block_device[0].volume_id]
#   }

#   lifecycle {
#     # The EC2 instance will have an encrypted root volume.
#     postcondition {
#       condition     = self.encrypted
#       error_message = "The server's root volume is not encrypted."
#     }
#   }
# }

# output "api_base_url" {
#   value = "https://${aws_instance.example.private_dns}:8433/"
# }