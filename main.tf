provider "aws" {
  region = "us-east-1" # Change if you prefer another region
}

# Create a Security Group to allow Web and SSH traffic
resource "aws_security_group" "web_sg" {
  name        = "adnan_web_sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS for us-east-1
  instance_type = "t3.micro"
  security_groups = [aws_security_group.web_sg.name]

  # This script runs when the server starts
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              sudo systemctl start docker
              sudo systemctl enable docker
              # Pull and run the docker image
              sudo docker run -d -p 80:80 iamadnanakram/adnan-test-site:latest
              EOF

  tags = {
    Name = "Adnan-Test-Server"
  }
}

# Output the public IP so you can easily click it in Jenkins
output "public_ip" {
  value = aws_instance.web_server.public_ip
}

