module "public_servers" {
  source           = "./InstanceModule"
  name            = var.env_name
  subnets          = module.vpc.public_subnets
  instance_type   = var.instance_type
  ami_id           = data.aws_ami.ubuntu.id
  key_name         = aws_key_pair.terraform-key.key_name
  security_groups  = [aws_security_group.web.id]
  user_data        = var.nginx_install
  tags             = {Name = "web server"}
}

module "private_servers" {
  source          = "./InstanceModule"
  name            = var.env_name
  subnets         = module.vpc.private_subnets
  instance_type   = var.instance_type
  ami_id          = data.aws_ami.ubuntu.id
  key_name        = aws_key_pair.terraform-key.key_name
  security_groups = [aws_security_group.db.id]
  user_data       = null
  tags            = {Name = "db server"}
}