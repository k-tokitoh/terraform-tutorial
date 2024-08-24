provider "aws" {
  profile = "private"
  region  = "us-east-1"
}

resource "aws_instance" "hello-world" {
  # マネジメントコンソールで確認してコピペ
  ami           = "ami-066784287e358dad1"
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-tutorial"
  }

  # nginxをインストールして起動する
  user_data = <<EOF
#!/bin/bash
amazon-linux-extras install -y nginx1.12
systemctl start nginx
EOF
}
