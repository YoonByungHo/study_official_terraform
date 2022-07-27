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
module "bucket" {
  for_each = toset(["assets", "media"])
  source   = "./publish_bucket"
  name     = "${each.key}_bucket"
}


