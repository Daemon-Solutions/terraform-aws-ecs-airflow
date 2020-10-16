resource "aws_db_instance" "airflow" {
  name                      = "${var.resource_prefix}-airflow-${var.resource_suffix}"
  allocated_storage         = 20
  storage_type              = "standard"
  engine                    = "postgres"
  engine_version            = "11.8"
  instance_class            = var.rds_instance_class
  username                  = var.rds_username
  password                  = var.rds_password
  multi_az                  = false
  availability_zone         = var.rds_availability_zone
  publicly_accessible       = false
  deletion_protection       = var.rds_deletion_protection
  final_snapshot_identifier = "airflow-final-snapshot-${local.timestamp_sanitized}"
  identifier                = "airflow"
  vpc_security_group_ids    = [aws_security_group.airflow.id]
  db_subnet_group_name      = aws_db_subnet_group.airflow.name

  tags = local.common_tags
}

resource "aws_db_subnet_group" "airflow" {
  name       = "${var.resource_prefix}-airflow-${var.resource_suffix}"
  subnet_ids = [var.public_subnet_id, var.backup_public_subnet_id]

  tags = local.common_tags
}


locals {
  timestamp           = timestamp()
  timestamp_sanitized = replace(local.timestamp, "/[- TZ:]/", "")
}