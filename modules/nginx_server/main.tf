resource "aws_instance" "server" {
  ami           = "ami-066784287e358dad1"
  instance_type = var.instance_type

  tags = {
    Name = "terraformTutorial-moduleTest-nginxServer"
  }

  # 起動するためのスクリプト
  user_data = <<-EOF
              #!/bin/bash
              amazon-linux-extras install nginx1.12 -y
              systemctl start nginx
              EOF
}
