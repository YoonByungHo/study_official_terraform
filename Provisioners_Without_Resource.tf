# Provisioners Without a Resource

# null_resource의 인스턴스는 일반 리소스처럼 처리되지만 아무 작업도 수행하지 않습니다. 
# 다른 리소스와 마찬가지로 null_resource에서 프로비저닝 도구 및 연결 세부 정보를 구성할 수 있습니다. 
# 또한 트리거 인수와 메타 인수를 사용하여 종속성 그래프에서 프로비져너가 실행될 위치를 정확히 제어할 수 있습니다.


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

resource "aws_security_group_rule" "inbound_example_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"

  security_group_id = aws_security_group.example.id
  source_security_group_id = aws_security_group.example.id
  depends_on = [
    aws_security_group.example,
  ]
}

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
  subnet_id = "subnet-094917711e29f22f5"
  vpc_security_group_ids = [ aws_security_group.example.id ]
#   user_data = <<EOF
# #!/bin/bash
# echo "this is test" >> /home/ec2-user/test.txt
# EOF

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

resource "null_resource" "example" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", aws_instance.example.*.id)}"
  }
  connection {
    host = "${element(aws_instance.example.*.public_ip, 0)}"
  }
  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "bootstrap-cluster.sh ${join(" ", aws_instance.example.*.private_ip)}",
    ]
  }
}

