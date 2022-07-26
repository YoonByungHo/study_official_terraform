# Meta-Arguments

# ------------------------------------------------------------------------------------------------------
# 1. The depends_on Meta-Argument
# Terraform이 자동으로 유추할 수 없는 숨겨진 리소스 또는 모듈 종속성을 처리하려면 extends_on 메타 인수를 사용하십시오. 
# 리소스 또는 모듈이 다른 리소스의 동작에 의존하지만 인수에서 해당 리소스의 데이터에 액세스하지 않는 경우에만 종속성을 명시적으로 지정하면 됩니다.

resource "aws_iam_role" "example" {
  name = "example"

  # assume_role_policy is omitted for brevity in this example. Refer to the
  # documentation for aws_iam_role for a complete example.
  assume_role_policy = "..."
}

resource "aws_iam_instance_profile" "example" {
  # Because this expression refers to the role, Terraform can infer
  # automatically that the role must be created first.
  role = aws_iam_role.example.name
}

resource "aws_iam_role_policy" "example" {
  name   = "example"
  role   = aws_iam_role.example.name
  policy = jsonencode({
    "Statement" = [{
      # This policy allows software running on the EC2 instance to
      # access the S3 API.
      "Action" = "s3:*",
      "Effect" = "Allow",
    }],
  })
  depends_on = [
    aws_iam_role.example
  ]
}

resource "aws_instance" "example" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  # Terraform can infer from this that the instance profile must
  # be created before the EC2 instance.
  iam_instance_profile = aws_iam_instance_profile.example

  # However, if software running in this EC2 instance needs access
  # to the S3 API in order to boot properly, there is also a "hidden"
  # dependency on the aws_iam_role_policy that Terraform cannot
  # automatically infer, so it must be declared explicitly:
  depends_on = [
    aws_iam_role_policy.example
  ]
}
