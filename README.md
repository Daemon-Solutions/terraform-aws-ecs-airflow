[![Maintained by dataroots](https://img.shields.io/badge/maintained%20by-dataroots-%2300b189)](https://dataroots.io)
[![Airflow version](https://img.shields.io/badge/Apache%20Airflow-1.10.12-e27d60.svg)]()
[![Terraform 0.13](https://img.shields.io/badge/terraform-0.13-%23623CE4)](https://www.terraform.io)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-%23623CE4)](https://registry.terraform.io/modules/datarootsio/aws-airflow/module/)
[![Tests](https://github.com/datarootsio/terraform-aws-ecs-airflow/workflows/tests/badge.svg?branch=master)](https://github.com/datarootsio/terraform-aws-ecs-airflow/actions)
[![Go Report Card](https://goreportcard.com/badge/github.com/datarootsio/terraform-aws-ecs-airflow)](https://goreportcard.com/report/github.com/datarootsio/terraform-aws-ecs-airflow)

# Terraform module Airflow on AWS ECS

This is a module for Terraform that deploys Airflow in AWS.

## Setup

- An ECS Cluster with:
    - Sidecar injection container
    - Airflow webserver container
    - Airflow scheduler container
- An ALB
- A RDS instance (optional but recommended)
- A DNS Record (optional but recommended)
- A S3 Bucket (optional)

Average cost of the minimal setup (with RDS): ~40$/Month

Why do I need a RDS instance? 
1. This makes Airflow statefull, you will be able to rerun failed dags, keep history of failed/succeeded dags, ...
2. It allows for dags to run concurrently, otherwise two dags will not be able to run at the same time
3. The state of your dags persists, even if the Airflow container fails or if you update the container definition (this will trigger an update of the ECS task)

## Intend

The Airflow setup provided with this module, is a setup where the only task of Airflow is to manage your jobs/workflows. So not to do actually heavy lifting like SQL queries, Spark jobs, ... . Offload as many task to AWS Lambda, AWS EMR, AWS Glue, ... . If you want Airflow to have access to these services, use the output role and give it permissions to these services through IAM.

## Usage

```hcl
module "airflow" {
    source = "datarootsio/aws-airflow/module/"

    resource_prefix = "my-awesome-company"
    resource_suffix = "env"

    vpc_id             = "vpc-123456"
    public_subnet_ids  = ["subnet-456789", "subnet-098765"]
}
```
(This will create Airflow, backed up by an RDS (both in a public subnet) and without https)

[Press here to see more examples](https://github.com/datarootsio/terraform-aws-ecs-airflow/tree/main/examples)

Note: After that Terraform is done deploying everything, it can take up to a minute for Airflow to be available through HTTP(S)

## Adding DAGs

To add dags, upload them to the created S3 bucket in the subdir "dags/". After you uploaded them run the seed dag. This will sync the s3 bucket with the local dags folder of the ECS container. 

## Todo

- [ ] RDS Backup options
- [ ] Option to use SQL instead of Postgres
- [ ] Add a Lambda function that triggers the sync dag (so that you can auto sync through ci/cd)
- [ ] RBAC
- [ ] Support for [Google OAUTH ](https://airflow.readthedocs.io/en/latest/security.html#google-authentication)

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13 |
| aws | ~> 3.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.12.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| airflow\_container\_home | Working dir for airflow (only change if you are using a different image) | `string` | `"/opt/airflow"` | no |
| airflow\_example\_dag | Add an example dag on startup (mostly for sanity check) | `bool` | `true` | no |
| airflow\_executor | The executor mode that airflow will use. Only allowed values are "Local" and "Sequential". "Local": Run DAGs in parallel (will created a RDS); "Local": You can not run DAGs in parallel (will NOT created a RDS); | `string` | `"Local"` | no |
| airflow\_image\_name | The name of the airflow image | `string` | `"apache/airflow"` | no |
| airflow\_image\_tag | The tag of the airflow image | `string` | `"1.10.12"` | no |
| airflow\_log\_region | The region you want your airflow logs in, defaults to the region variable | `string` | `""` | no |
| airflow\_log\_retention | The number of days you want to keep the log of airflow container | `string` | `"7"` | no |
| airflow\_py\_requirements\_path | The relative path to a python requirements.txt file to install extra packages in the container that you can use in your DAGs. | `string` | `""` | no |
| airflow\_variables | The variables passed to airflow as an environment variable (see airflow docs for more info https://airflow.apache.org/docs/). You can not specify "AIRFLOW\_\_CORE\_\_SQL\_ALCHEMY\_CONN" and "AIRFLOW\_\_CORE\_\_EXECUTOR" (managed by this module) | `map(string)` | `{}` | no |
| certificate\_arn | The ARN of the certificate that will be used | `string` | `""` | no |
| dns\_name | The DNS name that will be used to expose Airflow. Optional if not serving over HTTPS. Will be autogenerated if not provided | `string` | `""` | no |
| ecs\_cpu | The allocated cpu for your airflow instance | `number` | `1024` | no |
| ecs\_memory | The allocated memory for your airflow instance | `number` | `2048` | no |
| extra\_tags | Extra tags that you would like to add to all created resources | `map(string)` | `{}` | no |
| ip\_allow\_list | A list of ip ranges that are allowed to access the airflow webserver, default: full access | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| postgres\_uri | The postgres uri of your postgres db, if none provided a postgres db in rds is made. Format "<db\_username>:<db\_password>@<db\_endpoint>:<db\_port>/<db\_name>" | `string` | `""` | no |
| private\_subnet\_ids | A list of subnet ids of where the ECS and RDS reside, this will only work if you have a NAT Gateway in your VPC | `list(string)` | `[]` | no |
| public\_subnet\_ids | A list of subnet ids of where the ALB will reside, if the no "private\_subnet\_ids" is provided ECS and RDS will also reside in these subnets | `list(string)` | n/a | yes |
| rds\_availability\_zone | Availability zone for the rds instance | `string` | n/a | yes |
| rds\_deletion\_protection | Deletion protection for the rds instance | `bool` | n/a | yes |
| rds\_instance\_class | The class of instance you want to give to your rds db | `string` | `"db.t2.micro"` | no |
| rds\_password | Password of rds | `string` | n/a | yes |
| rds\_username | Username of rds | `string` | n/a | yes |
| region | The region to deploy your solution to | `string` | `"eu-west-1"` | no |
| resource\_prefix | A prefix for the create resources, example your company name | `string` | n/a | yes |
| resource\_suffix | A suffix for the created resources, example the environment for airflow to run in | `string` | n/a | yes |
| route53\_zone\_name | The name of a Route53 zone that will be used for the certificate validation. | `string` | `""` | no |
| s3\_bucket\_name | The S3 bucket name where the DAGs and startup scripts will be stored, leave this blank to let this module create a s3 bucket for you. WARNING: this module will put files into the path "dags/" and "startup/" of the bucket | `string` | `""` | no |
| use\_https | Expose traffic using HTTPS or not | `bool` | `false` | no |
| vpc\_id | The id of the vpc where you will run ecs/rds | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| airflow\_alb\_dns | The DNS name of the ALB, with this you can access the Airflow webserver |
| airflow\_connection\_sg | The security group with which you can connect other instance to Airflow, for example EMR Livy |
| airflow\_dns\_record | The created DNS record (only if "use\_https" = true) |
| airflow\_task\_iam\_role | The IAM role of the airflow task, use this to give Airflow more permissions |

<!--- END_TF_DOCS --->

## Makefile Targets

```text
Available targets:

  tools                             Pull Go and Terraform dependencies
  fmt                               Format Go and Terraform code
  lint/lint-tf/lint-go              Lint Go and Terraform code
  test/testverbose                  Run tests

```

## Contributing

Contributions to this repository are very welcome! Found a bug or do you have a suggestion? Please open an issue. Do you know how to fix it? Pull requests are welcome as well! To get you started faster, a Makefile is provided.

Make sure to install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html), [Go](https://golang.org/doc/install) (for automated testing) and Make (optional, if you want to use the Makefile) on your computer. Install [tflint](https://github.com/terraform-linters/tflint) to be able to run the linting.

* Setup tools & dependencies: `make tools`
* Format your code: `make fmt`
* Linting: `make lint`
* Run tests: `make test` (or `go test -timeout 2h ./...` without Make)

## License

MIT license. Please see [LICENSE](LICENSE.md) for details.