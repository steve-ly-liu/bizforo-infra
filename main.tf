#-------- main.tf --------
#============================
terraform {
  required_providers {
    aws = {
      version = "~> 4.16.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

#Deploy Networking Resources
#================================
module "vpc" {
  source = "./modules/vpc"
}

#Deploy Compute Resources
#=========================
module "compute" {
  source         = "./modules/compute"
  subnets        = module.vpc.bf_public_subnets
  security_group = module.vpc.bf_public_sg
  subnet_ips     = module.vpc.bf_subnet_ips
}