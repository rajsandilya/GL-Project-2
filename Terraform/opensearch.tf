resource "aws_security_group" "opensearch_sg" {
  name        = "opensearch-sg"
  description = "Security group for OpenSearch"
  vpc_id      = var.vpc_id

  # You can tighten this later; for now allow HTTPS from VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # for lab/demo; restrict in real env
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "opensearch-sg"
  })
}

resource "aws_opensearch_domain" "search" {
  domain_name    = var.opensearch_domain_name
  engine_version = "OpenSearch_2.11"

  cluster_config {
    instance_type  = "r8g.large.search"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp3"
  }

  vpc_options {
    subnet_ids         = [var.public_subnets[0]]
    security_group_ids = [aws_security_group.opensearch_sg.id]
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true

    master_user_options {
      master_user_name     = var.opensearch_master_user
      master_user_password = var.opensearch_master_password
    }
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  tags = merge(var.tags, {
    Name = "search-engine-opensearch"
  })
}
