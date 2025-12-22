# Application Load Balancer Configuration

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = ["subnet-0b5f44f6a7c3f2a17", "subnet-0dcf98e23a5861550", "subnet-0342cfb028d6aff5a"]

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }

  lifecycle {
    ignore_changes = [subnets]
  }
}

# Blue Target Group
resource "aws_lb_target_group" "blue" {
  name        = "${var.project_name}-blue-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/_health"
    protocol            = "HTTP"
    matcher             = "200,204"
  }

  deregistration_delay = 30

  tags = {
    Name = "${var.project_name}-blue-tg"
  }
}

# Green Target Group
resource "aws_lb_target_group" "green" {
  name        = "${var.project_name}-green-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/_health"
    protocol            = "HTTP"
    matcher             = "200,204"
  }

  deregistration_delay = 30

  tags = {
    Name = "${var.project_name}-green-tg"
  }
}

# ALB Listener (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# ALB Listener (HTTPS) - Optional, can be configured later with SSL certificate
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = var.ssl_certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.blue.arn
#   }
# }

# CloudWatch Alarms for ALB
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts_blue" {
  alarm_name          = "${var.project_name}-alb-unhealthy-hosts-blue"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when ALB Blue target group has unhealthy targets"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.blue.arn_suffix
  }

  tags = {
    Name = "${var.project_name}-alb-unhealthy-blue-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts_green" {
  alarm_name          = "${var.project_name}-alb-unhealthy-hosts-green"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Alert when ALB Green target group has unhealthy targets"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.green.arn_suffix
  }

  tags = {
    Name = "${var.project_name}-alb-unhealthy-green-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${var.project_name}-alb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "Alert when target response time is high"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${var.project_name}-alb-response-time-alarm"
  }
}
