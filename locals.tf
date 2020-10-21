locals {
  module_name = "terraform-aws-ecs-airflow"

  own_tags = {
    Name      = "${var.resource_prefix}-airflow-${var.resource_suffix}"
    CreatedBy = "Terraform"
    Module    = local.module_name
  }
  common_tags = merge(local.own_tags, var.extra_tags)

  rds_name             = "${var.resource_prefix}-airflow-${var.resource_suffix}"
  created_postgres_uri = "${var.rds_username}:${var.rds_password}@${aws_db_instance.airflow.address}:${aws_db_instance.airflow.port}/${aws_db_instance.airflow.name}"
  postgres_uri         = var.postgres_uri != "" ? var.postgres_uri : local.created_postgres_uri

  s3_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : aws_s3_bucket.airflow[0].id
  s3_key         = ""

  airflow_webserver_container_name = "${var.resource_prefix}-airflow-webserver-${var.resource_suffix}"
  airflow_scheduler_container_name = "${var.resource_prefix}-airflow-scheduler-${var.resource_suffix}"
  airflow_sidecar_container_name   = "${var.resource_prefix}-airflow-sidecar-${var.resource_suffix}"
  airflow_volume_name              = "airflow"

  airflow_container_home = "/opt/airflow"

  rds_ecs_subnet_id        = var.private_subnet_id != "" ? var.private_subnet_id : var.public_subnet_id
  rds_ecs_backup_subnet_id = var.backup_private_subnet_id != "" ? var.backup_private_subnet_id : var.backup_public_subnet_id

  dns_record      = var.dns_name != "" ? var.dns_name : (var.route53_zone_name != "" ? "${var.resource_prefix}-airflow-${var.resource_suffix}.${data.aws_route53_zone.zone[0].name}" : "")
  certificate_arn = var.use_https ? (var.certificate_arn != "" ? var.certificate_arn : aws_acm_certificate.cert[0].arn) : ""
}