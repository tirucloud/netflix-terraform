resource "aws_security_group" "Project-SG" {
  name        = var.security_group
  description = "Open 22,443,80,8080,9000,8082"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000, 8081, 8082, 9090] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Project-SG"
  }
}


resource "aws_instance" "jenkins" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.Project-SG.id]
  user_data              = templatefile("./jenkins.sh", {})

  tags = {
    Name = "jenkins"
  }
  root_block_device {
    volume_size = 29
  }
}

resource "aws_instance" "monitoring" {
  ami                    = var.ami
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.Project-SG.id]
  user_data              = templatefile("./monitor.sh", { PROM_VERSION = "2.52.0" })

  tags = {
    Name = "monitoring"
  }
  root_block_device {
    volume_size = 29
  }
}
