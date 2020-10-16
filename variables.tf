variable "resource_prefix" {
  type        = string
  description = "A prefix for the create resources, example your company name"
  default     = "dataroots"
}

variable "resource_suffix" {
  type        = string
  description = "A suffix for the created resources, example the environment for airflow to run in"
  default     = "dev"
}

variable "extra_tags" {
  description = "Extra tags that you would like to add to all created resources"
  type        = map(string)
  default     = {}
}

// Airflow variables
variable "airflow_image_name" {
  type        = string
  description = "The name of the airflow image"
  default     = "puckel/docker-airflow"
}

variable "airflow_image_tag" {
  type        = string
  description = "The tag of the airflow image"
  default     = "1.10.9"
}

variable "airflow_log_region" {
  type        = string
  description = "The region you want your airflow logs in"
}

variable "airflow_log_retention" {
  type        = string
  description = "The number of days you want to keep the log of airflow container"
  default     = "7"
}

variable "airflow_navbar_color" {
  type        = string
  description = "The color of the airflow navbar; good way to distinguish your dev/stag/prod airflow"
  default     = "#007A87"
}

// ECS variables
variable "ecs_cpu" {
  type        = number
  description = "The allocated cpu for your airflow instance"
  default     = 1024
}

variable "ecs_memory" {
  type        = number
  description = "The allocated memory for your airflow instance"
  default     = 2048
}

// Networking variables
variable "vpc_id" {
  type        = string
  description = "The id of the vpc where you will run ecs/rds"
}

variable "public_subnet_id" {
  type        = string
  description = "The id of a public subnet for the alb/rds/ecs task to be in"
}

variable "backup_public_subnet_id" {
  type        = string
  description = "The id of a public backup subnet for the alb to be in"
}

// RDS variables
variable "rds_username" {
  type        = string
  description = "Username of rds"
}

variable "rds_password" {
  type        = string
  description = "Password of rds"
}

variable "rds_instance_class" {
  type        = string
  description = "The class of instance you want to give to your rds db"
  default     = "db.t2.micro"
}

variable "rds_availability_zone" {
  type        = string
  description = "Availability zone for the rds instance"
}

variable "rds_deletion_protection" {
  type        = bool
  description = "Deletion protection for the rds instance"
}

// S3 Bucket
variable "s3_bucket_name" {
  type        = string
  default     = ""
  description = "The S3 bucket name where the DAG seed will be stored"
}
