region = "eu-west-1"

name        = "DEMO"
project     = "sandbox build"
environment = "testing"
managedby   = "Alejandro"

vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidr = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
