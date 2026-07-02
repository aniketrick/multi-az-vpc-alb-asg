data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  user_data = <<-EOT
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y python3
    mkdir -p /opt/demo-app
    cat > /opt/demo-app/app.py <<'PY'
    from http.server import BaseHTTPRequestHandler, HTTPServer
    import socket

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            body = f"Multi-AZ VPC demo app is healthy. Served by {socket.gethostname()}\n"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(body.encode("utf-8"))

    HTTPServer(("0.0.0.0", ${var.app_port}), Handler).serve_forever()
    PY
    cat > /etc/systemd/system/demo-app.service <<'SERVICE'
    [Unit]
    Description=Demo Python web app
    After=network.target

    [Service]
    ExecStart=/usr/bin/python3 /opt/demo-app/app.py
    Restart=always
    User=root

    [Install]
    WantedBy=multi-user.target
    SERVICE
    systemctl daemon-reload
    systemctl enable demo-app
    systemctl start demo-app
  EOT
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name}-lt-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(local.user_data)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name}-app"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name}-launch-template"
  })
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "ELB"
  health_check_grace_period = 180
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Name = "${var.name}-asg-instance" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.name}-asg-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "High CPU alarm for demo Auto Scaling Group instances"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = var.tags
}
