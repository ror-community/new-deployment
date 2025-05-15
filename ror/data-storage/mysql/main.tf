resource "aws_db_instance" "db" {
  identifier                  = "db"
  storage_type                = "gp2"
  allocated_storage           = 10
  engine                      = "mysql"
  engine_version              = "8.0.36"
  instance_class              = "db.t3.micro"
  username                    = var.mysql_user
  db_subnet_group_name        = "ror"
  password                    = var.mysql_password
  name                        = "rorapi"
  maintenance_window          = "Mon:00:00-Mon:01:00"
  backup_window               = "17:00-17:30"
  backup_retention_period     = 1
  availability_zone           = "eu-west-1a"
  vpc_security_group_ids      = [var.private_security_group]
  parameter_group_name        = "ror-mysql8"
  auto_minor_version_upgrade  = "true"
  allow_major_version_upgrade = "true"
  max_allocated_storage       = 20
  multi_az                    = "true"
  publicly_accessible         = "false"

  tags = {
    Name = "production"
  }

  lifecycle {
    prevent_destroy = "true"
    ignore_changes  = [
      engine_version
     ]
  }

  apply_immediately = "true"
  depends_on        = [
    aws_db_subnet_group.ror,
    aws_db_parameter_group.ror-mysql8
  ]
}

resource "aws_db_parameter_group" "ror-mysql8" {
  name        = "ror-mysql8"
  family      = "mysql8.0"
  description = "RDS ror mysql8 parameter group"

  parameter {
	name  = "character_set_server"
	value = "utf8mb4"
  }
  parameter {
	name  = "collation_server"
	value = "utf8mb4_unicode_ci"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "max_allowed_packet"
    value = 50000000
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }
}

resource "aws_db_subnet_group" "ror" {
  name       = "ror"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "RDS subnet group for production"
  }
}