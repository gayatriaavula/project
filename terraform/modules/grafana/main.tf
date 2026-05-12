# ── CloudWatch log groups ──────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "prometheus" {
  name              = "/ecs/${var.app_name}-${var.environment}-prometheus"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/${var.app_name}-${var.environment}-grafana"
  retention_in_days = var.log_retention_days
}

# ── Security group for monitoring ALB ─────────────────────────────────────────
resource "aws_security_group" "monitoring_alb" {
  name        = "${var.app_name}-${var.environment}-monitoring-alb-sg"
  description = "Allow HTTP access to the monitoring load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.app_name}-${var.environment}-monitoring-alb-sg", Environment = var.environment }
}

# ── Security group for monitoring tasks ───────────────────────────────────────
resource "aws_security_group" "monitoring_tasks" {
  name        = "${var.app_name}-${var.environment}-monitoring-tasks-sg"
  description = "Prometheus and Grafana ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring_alb.id]
  }

  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring_alb.id]
  }

  ingress {
    from_port = 9090
    to_port   = 9090
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.app_name}-${var.environment}-monitoring-tasks-sg", Environment = var.environment }
}

# ── IAM role for monitoring tasks ─────────────────────────────────────────────
resource "aws_iam_role" "monitoring_task_execution" {
  name = "${var.app_name}-${var.environment}-monitoring-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring_execution" {
  role       = aws_iam_role.monitoring_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Grafana needs read access to CloudWatch for dashboards
resource "aws_iam_role" "grafana_task" {
  name = "${var.app_name}-${var.environment}-grafana-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "grafana_cloudwatch" {
  name = "cloudwatch-read"
  role = aws_iam_role.grafana_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cloudwatch:DescribeAlarmsForMetric",
        "cloudwatch:DescribeAlarmHistory",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricData",
        "cloudwatch:GetInsightRuleReport",
        "logs:DescribeLogGroups",
        "logs:GetLogGroupFields",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults",
        "logs:GetLogEvents",
        "ec2:DescribeTags",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "tag:GetResources"
      ]
      Resource = "*"
    }]
  })
}

# ── Monitoring ALB ─────────────────────────────────────────────────────────────
resource "aws_lb" "monitoring" {
  name                       = "${var.app_name}-${var.environment}-monitoring-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.monitoring_alb.id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
  tags = { Environment = var.environment }
}

resource "aws_lb_target_group" "grafana" {
  name        = "${var.app_name}-${var.environment}-grafana-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/api/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200"
  }
  tags = { Environment = var.environment }
}

resource "aws_lb_target_group" "prometheus" {
  name        = "${var.app_name}-${var.environment}-prometheus-tg"
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/-/healthy"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200"
  }
  tags = { Environment = var.environment }
}

resource "aws_lb_listener" "monitoring" {
  load_balancer_arn = aws_lb.monitoring.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana.arn
  }
}

resource "aws_lb_listener_rule" "prometheus" {
  listener_arn = aws_lb_listener.monitoring.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus.arn
  }
  condition {
    path_pattern { values = ["/prometheus*", "/graph*", "/api/v1*"] }
  }
}

# ── Prometheus task definition ─────────────────────────────────────────────────
resource "aws_ecs_task_definition" "prometheus" {
  family                   = "${var.app_name}-${var.environment}-prometheus"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.monitoring_task_execution.arn

  container_definitions = jsonencode([{
    name  = "prometheus"
    image = "prom/prometheus:latest"
    portMappings = [{ containerPort = 9090, protocol = "tcp" }]
    command = [
      "--config.file=/etc/prometheus/prometheus.yml",
      "--web.external-url=/prometheus",
      "--web.route-prefix=/prometheus"
    ]
    environment = [{
      name  = "BACKEND_ALB"
      value = var.backend_alb_dns
    }]
    # Inline prometheus config via entrypoint override
    entryPoint = ["/bin/sh", "-c"]
    command = [
      "echo 'global:\\n  scrape_interval: 15s\\nscrape_configs:\\n  - job_name: backend\\n    metrics_path: /metrics\\n    static_configs:\\n      - targets: [\"${var.backend_alb_dns}:80\"]' > /etc/prometheus/prometheus.yml && /bin/prometheus --config.file=/etc/prometheus/prometheus.yml --web.external-url=/prometheus --web.route-prefix=/prometheus"
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.prometheus.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "prometheus"
      }
    }
  }])
}

# ── Grafana task definition ────────────────────────────────────────────────────
resource "aws_ecs_task_definition" "grafana" {
  family                   = "${var.app_name}-${var.environment}-grafana"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.monitoring_task_execution.arn
  task_role_arn            = aws_iam_role.grafana_task.arn

  container_definitions = jsonencode([{
    name  = "grafana"
    image = "grafana/grafana:latest"
    portMappings = [{ containerPort = 3000, protocol = "tcp" }]
    environment = [
      { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_admin_password },
      { name = "GF_SECURITY_ADMIN_USER", value = "admin" },
      { name = "GF_SERVER_ROOT_URL", value = "http://${aws_lb.monitoring.dns_name}" },
      { name = "GF_AUTH_ANONYMOUS_ENABLED", value = "false" },
      { name = "GF_INSTALL_PLUGINS", value = "grafana-clock-panel" },
      { name = "AWS_DEFAULT_REGION", value = var.aws_region },
      # Auto-provision CloudWatch data source
      { name = "GF_DATASOURCES_DEFAULT_TYPE", value = "cloudwatch" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "grafana"
      }
    }
  }])
}

# ── ECS Services ───────────────────────────────────────────────────────────────
resource "aws_ecs_service" "prometheus" {
  name            = "${var.app_name}-${var.environment}-prometheus"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.prometheus.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.monitoring_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prometheus.arn
    container_name   = "prometheus"
    container_port   = 9090
  }

  depends_on = [aws_lb_listener.monitoring]
}

resource "aws_ecs_service" "grafana" {
  name            = "${var.app_name}-${var.environment}-grafana"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.monitoring_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana.arn
    container_name   = "grafana"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.monitoring]
}
