# Meta-Arguments

# ------------------------------------------------------------------------------------------------------
# 1. The depends_on Meta-Argument
# Terraform이 자동으로 유추할 수 없는 숨겨진 리소스 또는 모듈 종속성을 처리하려면 extends_on 메타 인수를 사용하십시오. 
# 리소스 또는 모듈이 다른 리소스의 동작에 의존하지만 인수에서 해당 리소스의 데이터에 액세스하지 않는 경우에만 종속성을 명시적으로 지정하면 됩니다.
# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# resource "aws_iam_role" "example" {
#   name = "example"

#   # assume_role_policy is omitted for brevity in this example. Refer to the
#   # documentation for aws_iam_role for a complete example.
#   assume_role_policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Principal": {
#                 "Service": "ec2.amazonaws.com"
#             },
#             "Action": "sts:AssumeRole"
#         }
#     ]
# }
# POLICY
# }

# resource "aws_iam_instance_profile" "example" {
#   # Because this expression refers to the role, Terraform can infer
#   # automatically that the role must be created first.
#   role = aws_iam_role.example.name
# }

# resource "aws_iam_role_policy" "example" {
#   name   = "example"
#   role   = aws_iam_role.example.name
#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:GetObject",
#                 "s3:PutObject",
#                 "s3:DeleteObject",
#                 "s3:ListBucket"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::*"
#             ]
#         }
#     ]
#   })
#   depends_on = [
#     aws_iam_role.example
#   ]
# }

# resource "aws_instance" "example" {
#   ami           = data.aws_ami.example.id
#   instance_type = "t2.micro"

#   # Terraform can infer from this that the instance profile must
#   # be created before the EC2 instance.
#   iam_instance_profile = aws_iam_instance_profile.example.name

#   # However, if software running in this EC2 instance needs access
#   # to the S3 API in order to boot properly, there is also a "hidden"
#   # dependency on the aws_iam_role_policy that Terraform cannot
#   # automatically infer, so it must be declared explicitly:
#   depends_on = [
#     aws_iam_role_policy.example
#   ]
# }

# 2. The count Meta-Argument
# 기본적으로 리소스 블록은 하나의 실제 인프라 개체를 구성합니다. (마찬가지로, 모듈 블록은 자식 모듈의 내용을 한 번 구성에 포함합니다.) 
# 그러나 때로는 각각에 대해 별도의 블록을 작성하지 않고 여러 유사한 개체(컴퓨팅 인스턴스의 고정 풀과 같은)를 관리하고 싶을 때가 있습니다. 
# Terraform에는 count 및 for_each의 두 가지 방법이 있습니다.

# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# # count로 4개의 인스턴스가 생성됨
# resource "aws_instance" "server" {
#   count = 4 # create four similar EC2 instances

#   ami           = data.aws_ami.example.id
#   instance_type = "t2.micro"

#   tags = {
#     Name = "Server ${count.index}"
#   }
# }

# variable "subnet_ids" {
#   type = list(string)
#   default = []
# }

# # var.subnet_ids에 두개의 서브넷 아이디를 입력했으므로 2개의 인스턴스가 생성됨
# resource "aws_instance" "server" {
#   # Create one instance for each subnet
#   count = length(var.subnet_ids)

#   ami           = data.aws_ami.example.id
#   instance_type = "t2.micro"
#   subnet_id     = var.subnet_ids[count.index]

#   tags = {
#     Name = "Server ${count.index}"
#   }
# }

# The for_each Meta-Argument
# map:
# data "aws_ami" "example" {
#   most_recent      = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-*"]
#   }
# }

# # 리소스 내에서 map으로 정의 후 생성
# # key가 이름에 적용되고 value가 type 정의
# resource "aws_instance" "server" {
#   for_each = {
#     first = "t2.micro"
#     secon = "t2.micro"
#   }

#   ami           = data.aws_ami.example.id
#   instance_type = "${each.value}"

#   tags = {
#     Name = "Server ${each.key}"
#   }
# }

# set of string
# resource "aws_iam_user" "the-accounts" {
#   for_each = toset( ["Todd", "James", "Alice", "Dottie"] )
#   name     = each.key
# }

# Child module
# set에 정의된 버킷 이름을 publish_bucket의 main.tf로 던져서 버킷 생성
# set의 크기 = s3의 갯수
# module "bucket" {
#   for_each = toset(["assets", "media"])
#   source   = "./publish_bucket"
#   name     = "${each.key}bucketho12341234"
# }


# 3. The lifecycle Meta-Argument
# 리소스의 일반 수명 주기는 리소스 동작 페이지에 설명되어 있습니다. 해당 동작에 대한 일부 세부 정보는 리소스 블록 본문 내의 특수 중첩 수명 주기 블록을 사용하여 사용자 지정할 수 있습니다.

# create_before_destroy
# 기본적으로 Terraform이 원격 API 제한으로 인해 제자리에서 업데이트할 수 없는 리소스 인수를 변경해야 하는 경우 Terraform은 대신 기존 객체를 파괴한 
# 다음 새로 구성된 인수로 새 대체 객체를 생성합니다.
# 그러니까 replace가 안되는 경우 삭제되면 서비스가 내려갈 수 있으니까 업데이트된 자원을 생성 후 이전 자원을 삭제함, 원리가 불루그린 배포와 같음


# prevent_destroy
# 이 메타 인수를 true로 설정하면 구성에 인수가 남아 있는 한 Terraform이 리소스와 연결된 인프라 개체를 파괴하는 계획을 오류와 함께 거부합니다.
# 그냥 삭제 방지 기능


# ignore_changes
# 기본적으로 Terraform은 실제 인프라 개체의 현재 설정에서 차이를 감지하고 구성과 일치하도록 원격 개체를 업데이트할 계획입니다.
# 설명이 이해하기 어렵게 되어 있는데 테라폼에 의한 변경 사항인 것을 무시함


# replace_triggered_by
# Terraform 1.2에 추가되었습니다. 참조된 항목이 변경되면 리소스를 교체합니다. 관리 자원, 인스턴스 또는 인스턴스 속성을 참조하는 표현식 목록을 제공하십시오. 
# count 또는 for_each를 사용하는 리소스에서 사용하는 경우 표현식에서 count.index 또는 each.key를 사용하여 동일한 개수 또는 컬렉션으로 구성된 다른 리소스의 특정 인스턴스를 참조할 수 있습니다.

# Custom Condition Checks
# 수명 주기 블록과 함께 사전 조건 및 사후 조건 블록을 추가하여 리소스 및 데이터 원본이 작동하는 방식에 대한 가정 및 보장을 지정할 수 있습니다. 
# 다음 예제에서는 AMI가 올바르게 구성되었는지 확인하는 사전 조건을 생성합니다.

data "aws_ami" "example" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-arm64-*"]
  }
}

# 프리컨디션 조건에 걸려서 생성되지 않고 error_message를 뱉음
resource "aws_instance" "server" {

  ami           = data.aws_ami.example.id
  instance_type = "t2.micro"

  tags = {
    Name = "Server ${count.index}"
  }

precondition {
    condition     = data.aws_ami.example.architecture == "x86_64"
    error_message = "The selected AMI must be for the x86_64 architecture."
  }
}