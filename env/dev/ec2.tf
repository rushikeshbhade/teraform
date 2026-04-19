
# Use existing VPC
data "aws_vpc" "existing" {
  id = "vpc-00460aa54d6d3f8db"
}

# Use existing subnet
data "aws_subnet" "existing" {
  id = "subnet-06d7e52b785bd7dfa"
}

# Create security group inside existing VPC
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ restrict in real use
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance
resource "aws_instance" "my_ec2" {
  ami                    = "ami-0a1b6a02658659c2a" # change based on region
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnet.existing.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  key_name = "terraform_test" # optional (for SSH)

  tags = {
    Name = "MyEC2"
  }
}
