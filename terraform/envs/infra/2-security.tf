# ../envs/infra/security.tf
############################################
# SECURITY GROUPS
############################################
# Infra SG - admin + http + internal ping
module "project02_infra_sg" {
  source = "../../modules/security-group"
  name   = "project02-infra-sg"
  vpc_id = module.project02_vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 8080,
      to_port     = 8080,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "cAdvisor"
    },
    {
      from_port   = 22,
      to_port     = 22,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "SSH admin access"
    },
    {
      from_port   = 80,
      to_port     = 80,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "HTTP access"
    },
    {
      from_port   = 3000,
      to_port     = 3000,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "Grafana access"
    },
    {
      from_port   = 9090,
      to_port     = 9090,
      protocol    = "tcp",
      cidr_blocks = ["0.0.0.0/0"],
      description = "Prometheus access"
    },	
    {
      from_port   = -1,
      to_port     = -1,
      protocol    = "icmp",
      cidr_blocks = [module.project02_vpc.cidr_block],
      description = "internal ping test"
    }
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

# NAT instance security group
# → 내부 VPC만 inbound 허용 (security boundary)
resource "aws_security_group" "nat_sg" {
  vpc_id = module.project02_vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.project02_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# IAM ROLE & INSTANCE PROFILE (SSM)
############################################
resource "aws_iam_role" "ssm_role" {
  name = "project02-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "project02-ssm-profile"
  role = aws_iam_role.ssm_role.name
}













resource "aws_iam_role" "infra_role" {
  name = "project02-infra-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "infra_ssm_attach" {
  role       = aws_iam_role.infra_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "prometheus_discovery" {
  name = "project02-prometheus-discovery-policy"

  role = aws_iam_role.infra_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "PrometheusEC2Discovery"
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "infra_profile" {
  name = "project02-infra-profile"
  role = aws_iam_role.infra_role.name
}