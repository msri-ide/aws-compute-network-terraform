terraform {
  required_version = ">=1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
  backend "local" { #"s3"#
    #path           = terraform.tfstate
    #bucket         = "my_bucket_name"
    #key            = "path/to/my/key"
    #region         = "var.aws_region"
    #use_lockfile   = true
  }
}