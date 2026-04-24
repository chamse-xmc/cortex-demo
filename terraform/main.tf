provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "app_db" {
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  db_name                 = "appdb"
  username                = "admin"
  password                = "SuperSecret123!"
  skip_final_snapshot     = true
  storage_encrypted       = false
  publicly_accessible     = true
  backup_retention_period = 0
  deletion_protection     = false
}

resource "aws_s3_bucket" "uploads" {
  bucket = "myapp-user-uploads"
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  acl    = "public-read"
}

resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Security group for application servers"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  root_block_device {
    encrypted = false
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  monitoring                  = false
}

resource "aws_iam_policy" "app_policy" {
  name = "app-service-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/app/logs"
}

resource "aws_ebs_volume" "data_volume" {
  availability_zone = "us-east-1a"
  size              = 40
  encrypted         = false
}
