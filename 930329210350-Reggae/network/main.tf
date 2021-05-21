

module "vpc" {
  source              = "../../modules/tf-module-vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  igw                 = module.ig.igw_id
  natgw_ids           = module.natgw.natgw_ids
  name                = var.name
  project             = var.project
  environment         = var.environment
  managedby           = var.managedby

}

module "ig" {
  source      = "../../modules/tf-module-ig"
  vpc_id      = module.vpc.vpc_id
  name        = var.name
  project     = var.project
  environment = var.environment
  managedby   = var.managedby
}

module "natgw" {
  source            = "../../modules/tf-module-nat"
  public_subnet_ids = module.vpc.public_subnet_ids
  name              = var.name
  project           = var.project
  environment       = var.environment
  managedby         = var.managedby
}

module "domain_reggaetech" {
  source      = "../../modules/tf-module-dns"
  domain_name = "reggaetech.org"

}

module "domain_local" {
  source      = "../../modules/tf-module-dns"
  domain_name = "local.internal"
  vpc_id      = module.vpc.vpc_id
}


# module "test1_domain" {
#   source      = "../../modules/tf-module-dns"
#   domain_name = "test1.com"
# }

# module "test2_domain" {
#   source      = "../../modules/tf-module-dns"
#   domain_name = "test2.com"
#   vpc_id      = module.vpc.vpc_id
# }

module "jenkins_master" {
  source        = "../../modules/tf-module-ec2"
  quantity      = 2
  ami_id        = "ami-063d4ab14480ac177"
  instance_type = "t2.micro"
  key_name      = "sandbox_ireland"
  #subnet_id     = module.vpc.public_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  #assign_public_ip  = true
  assign_public_ip = false

  vpc_id = module.vpc.vpc_id

  availability_zones = var.availability_zones

}
