provider "aws" {
    region = "ap-northeast-2"
}

terraform {
    required_version = "0.13.5"
    required_providers {
        aws = ">=3.23.0"
    }
}