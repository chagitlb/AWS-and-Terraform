resource "aws_elb" "bar" {
    name = "terraform-elb"
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    listener {
        instance_port = 22
        instance_protocol = "http"
        lb_port = 22
        lb_protocol = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:80/"
        interval = 30
    }

    instances = module.public_servers.instance_id
    subnets = module.vpc.public_subnets
    security_groups = [aws_security_group.elb_securitygroup.id]
    cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400

    tags = {
        Name = "terraform-elb"
    }
}