# Intentionally vulnerable Terraform for Cortex Cloud demo
# DO NOT deploy this infrastructure

provider "aws" {
  region = "us-east-1"
}

# VULN: RDS instance without encryption, public access, no backup
resource "aws_db_instance" "demo_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "demo"
  username             = "admin"
  password             = "SuperSecret123!"  # CKV_SECRET: hardcoded password
  skip_final_snapshot  = true

  # Critical: no encryption at rest
  storage_encrypted = false

  # Critical: publicly accessible
  publicly_accessible = true

  # Critical: no backup retention
  backup_retention_period = 0

  # Critical: no deletion protection
  deletion_protection = false

  # Missing: no multi-AZ, no performance insights, no enhanced monitoring
}

# VULN: S3 bucket with no encryption, public access, no versioning, no logging
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "demo-vulnerable-bucket"
}

resource "aws_s3_bucket_public_access_block" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id

  # Critical: all public access allowed
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id
  acl    = "public-read"  # Critical: public read access
}

# VULN: Security group open to the world
resource "aws_security_group" "demo_sg" {
  name        = "demo-wide-open"
  description = "Intentionally insecure for demo"

  # Critical: SSH open to 0.0.0.0/0
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Critical: MySQL open to 0.0.0.0/0
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Critical: all outbound traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VULN: EC2 instance with no encryption, IMDSv1, public IP
resource "aws_instance" "demo_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_class = "t3.micro"

  # Critical: no encrypted root volume
  root_block_device {
    encrypted = false
  }

  # Critical: IMDSv1 (SSRF-exploitable)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"  # should be "required" for IMDSv2
  }

  # Critical: public IP
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  # Missing: no monitoring enabled
  monitoring = false
}

# VULN: IAM policy with wildcard permissions
resource "aws_iam_policy" "demo_admin" {
  name = "demo-overprivileged"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"        # Critical: full admin access
        Resource = "*"        # Critical: all resources
      }
    ]
  })
}

# VULN: CloudWatch log group with no encryption and no retention
resource "aws_cloudwatch_log_group" "demo_logs" {
  name = "/demo/app-logs"
  # Missing: no KMS encryption
  # Missing: no retention policy (logs kept forever)
}

# VULN: EBS volume unencrypted
resource "aws_ebs_volume" "demo_volume" {
  availability_zone = "us-east-1a"
  size              = 40
  encrypted         = false  # Critical: unencrypted volume
}
