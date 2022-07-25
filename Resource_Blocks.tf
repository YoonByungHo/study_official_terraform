#Resource Blocks

# ------------------------------------------------------------------------------------------------------
# Custom Condition Checks
# 사전 조건 및 사후 조건 블록을 사용하여 리소스 작동 방식에 대한 가정 및 보장을 지정할 수 있습니다. 다음 예에서는 AMI가 올바르게 구성되었는지 확인하는 사전 조건을 생성합니다.

# - 생성 되는 ami
# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# resource "aws_instance" "example" {
#   instance_type = "t2.micro"
#   ami           = data.aws_ami.example.id

#   lifecycle {
#     # The AMI ID must refer to an AMI that contains an operating system
#     # for the `x86_64` architecture.
#     precondition {
#       condition     = data.aws_ami.example.architecture == "x86_64"
#       error_message = "The selected AMI must be for the x86_64 architecture."
#     }
#   }
# }

# - 생성 안되는 ami
# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-arm64-*"]
#   }
# }

# resource "aws_instance" "example" {
#   instance_type = "t2.micro"
#   ami           = data.aws_ami.example.id

#   lifecycle {
#     # The AMI ID must refer to an AMI that contains an operating system
#     # for the `x86_64` architecture.
#     precondition {
#       condition     = data.aws_ami.example.architecture == "x86_64"
#       error_message = "The selected AMI must be for the x86_64 architecture."
#     }
#   }
# }

# ------------------------------------------------------------------------------------------------------
# Operation Timeouts
# 일부 리소스 유형은 특정 작업이 실패한 것으로 간주되기 전에 허용되는 시간을 사용자 지정할 수 있는 특별한 시간 초과 중첩 블록 인수를 제공합니다. 
# 예를 들어 aws_db_instance는 생성, 업데이트 및 삭제 작업에 대해 구성 가능한 시간 초과를 허용합니다.

# 시간 초과는 공급자의 리소스 유형 구현에 의해 완전히 처리되지만 이러한 기능을 제공하는 리소스 유형은 구성 가능한 시간 초과 값이 있는 각 작업의 이름을 
# 딴 중첩 인수가 있는 시간 초과라는 하위 블록을 정의하는 규칙을 따릅니다. 이러한 각 인수는 60분의 경우 "60m", 10초의 경우 "10s" 또는 2시간의 경우 "2h"와 같이 
# 지속 시간의 문자열 표현을 사용합니다.

# - 생성 시간이 1분으로 제한
# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# resource "aws_instance" "example" {
#   instance_type = "t2.micro"
#   ami           = data.aws_ami.example.id

#   timeouts {
#     create = "1m"
#     # delete = "2h"
#   }
# }

# - 생성 시간이 1초로 제한
data "aws_ami" "example" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
  }
}

resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.example.id

  timeouts {
    create = "1s"
    # delete = "1s"
  }
}
