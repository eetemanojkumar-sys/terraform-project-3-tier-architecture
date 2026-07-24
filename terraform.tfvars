aws_region   = "ap-south-1"
project_name = "threetier"
environment  = "dev"

vpc_cidr                 = "10.0.0.0/16"
azs                       = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs       = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
private_db_subnet_cidrs   = ["10.0.21.0/24", "10.0.22.0/24"]
single_nat_gateway         = true

instance_type     = "t3.micro"
key_name          = ""      # set your EC2 key pair name if you need SSH
min_size          = 2
max_size          = 4
desired_capacity  = 2

db_name           = "appdb"
db_username       = "admin"
# db_password is intentionally NOT set here - pass it via
# TF_VAR_db_password env var or a separate untracked *.auto.tfvars file
db_instance_class = "db.t3.micro"
