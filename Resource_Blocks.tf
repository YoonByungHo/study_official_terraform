#Resource Blocks



# Custom Condition Checks
# 사전 조건 및 사후 조건 블록을 사용하여 리소스 작동 방식에 대한 가정 및 보장을 지정할 수 있습니다. 다음 예에서는 AMI가 올바르게 구성되었는지 확인하는 사전 조건을 생성합니다.


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

  lifecycle {
    # The AMI ID must refer to an AMI that contains an operating system
    # for the `x86_64` architecture.
    precondition {
      condition     = data.aws_ami.example.architecture == "x86_64"
      error_message = "The selected AMI must be for the x86_64 architecture."
    }
  }
}
