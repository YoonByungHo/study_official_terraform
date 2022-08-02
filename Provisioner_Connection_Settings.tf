# Connection Block

# 원격 리소스에 액세스하는 방법을 설명하는 하나 이상의 연결 블록을 만들 수 있습니다. 
# 다중 연결을 제공하는 한 가지 사용 사례는 초기 제공자가 루트 사용자로 연결하여 사용자 계정을 설정하도록 한 다음 후속 제공자가 더 제한된 권한을 가진 사용자로 연결하도록 하는 것입니다.

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name      = "name"
    values    = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners      = ["amazon"]
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "example"
  vpc_id      = "vpc-07fcd32c280fc8256"
}

# resource "aws_security_group_rule" "inbound_example_22" {
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"

#   security_group_id = aws_security_group.example.id
#   source_security_group_id = aws_security_group.example.id
#   depends_on = [
#     aws_security_group.example,
#   ]
# }

# resource "aws_security_group_rule" "outbound_any" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 65535
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.example.id

#   depends_on = [
#     aws_security_group.example,
#   ]
# }

resource "aws_iam_role" "example" {
  name               = "example-role"
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_instance_profile" "example" {
  name = "example-profile"
  role = "${aws_iam_role.example.name}"
}

resource "aws_iam_role_policy_attachment" "example_attach_role" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  iam_instance_profile  = aws_iam_instance_profile.example.id
  security_groups = [ aws_security_group.example.id ]
  subnet_id = "subnet-0150c5d47b59b23a5"
  vpc_security_group_ids = [ aws_security_group.example.id ]
  user_data = <<EOF
#!/bin/bash
echo "this is test" >> /home/ec2-user/test.txt
EOF

# provisioner "file" {
#   source      = "${path.root}/test.txt"
#   destination = "${path.root}/test11.txt"

#   connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     private_key = "${file("/home/ec2-user/.ssh/id_rsa")}"
#     host     = "${self.private_dns}"
#   }
# }

  depends_on = [
    aws_security_group.example,
    aws_iam_role.example,
  ]

  tags                      = {
      "Name" = "example1"
  }
}

# resource "aws_instance" "example2" {
#   ami           = data.aws_ami.amazon_linux_2.id
#   instance_type = "t3.micro"
#   iam_instance_profile  = aws_iam_instance_profile.example.id
#   security_groups = [ aws_security_group.example.id ]
#   subnet_id = "subnet-0150c5d47b59b23a5"
#   vpc_security_group_ids = [ aws_security_group.example.id ]

#   depends_on = [
#     aws_security_group.example,
#     aws_iam_role.example
#   ]

#   tags                      = {
#       "Name" = "example2"
#   }
# }