terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2"
    }
    external = {
      source = "hashicorp/external"
      version = "~> 2.1"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.1"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.1"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.1"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

locals {
  name   = "dev"
  region = "eu-central-1"
  domain = "dlab.am"
  tags = {
    Owner       = "asaushkin@gmail.com"
    Environment = "dev"
    Name        = "dlab"
  }
}

