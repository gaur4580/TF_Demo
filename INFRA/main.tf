provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "vpc_module" {
  source                 = "../vpc_module"
  vpc_cidr               = "172.17.80.0/23"
  public_cidrs           = ["172.17.80.0/27", "172.17.80.32/27"]
  private_cidrs          = ["172.17.80.128/25", "172.17.81.0/25"]
  az                     = ["us-east-1a", "us-east-1b"]
  name                   = "Demo-test"
  private_subnets_per_az = "1"
  nat_gw_count = "1"
  ENV =  "Demo"
}

module "alb_module" {
  source    = "../alb_module"
  lb_name   = "tomcat-lb"
  security_groups = [module.sg.sg]
  subnets = [element( module.vpc_module.private_subnet_id ,0),element( module.vpc_module.private_subnet_id,1)]
  vpc_id = module.vpc_module.vpc_id
  build_http_listeners = "true"
  http_listner_rule_enabled = "false"
  tg_port = "8080"
}
module "alb_module_ext" {
  source    = "../alb_module"
  lb_name   = "web-lb"
  security_groups = [module.sg.sg]
  subnets = [element( module.vpc_module.public_subnet_id ,0),element( module.vpc_module.public_subnet_id,1)]
  vpc_id = module.vpc_module.vpc_id
  build_http_listeners = "true"
  http_listner_rule_enabled = "false"
  lb_internal = false
}
module "asg_tomcat" {
    source = "../asg_module"
    name                   = "tomcat-asg"
    subnets = [element( module.vpc_module.public_subnet_id ,0),element( module.vpc_module.public_subnet_id,1)]
    security_groups = [module.sg.sg]
    alb_arn = module.alb_module.tg_arn
}

module "asg_web" {
    source = "../asg_module"
    name                   = "web-asg"
    subnets = [element( module.vpc_module.public_subnet_id ,0),element( module.vpc_module.public_subnet_id,1)]
    security_groups = [module.sg.sg]
    alb_arn = module.alb_module_ext.tg_arn
}

module "sg" {
    source = "../sg"
    vpc_id = module.vpc_module.vpc_id
    name                   = "Demo-test"
}

module "rds" {
  source = "../rds_module"
  name = "testdb"
  username = "dbadmin"
  password = "dbadmin12345"
  db_instanse_size = "db.t2.micro"
  name_prefix = "test"
  subnets = [element( module.vpc_module.private_subnet_id ,0),element( module.vpc_module.private_subnet_id,1)]
}

module "route53_private" {
  source = "../r53_module"
  vpc_id = module.vpc_module.vpc_id
  r53_zone_name = "internal.com"
  alb_dns_name = module.alb_module.alb_dns_name
  alb_zone_id = module.alb_module.alb_zone_id
  record_name = "tomcat.internal.com"
}