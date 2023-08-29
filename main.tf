resource "aws_wafv2_web_acl" "rp_web_acl" {
  name        = var.waf_name
  description = "Web ACLc to attach to ALB"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }
  rule {
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WAF-ALB-Rule-Group"
      sampled_requests_enabled   = true
    }
    name     = "WAF-ALB-Rule-Group"
    priority = 0
    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.alb_rule_group.arn
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.metric_name
    sampled_requests_enabled   = true
  }

}

resource "aws_wafv2_rule_group" "alb_rule_group" {
  name        = var.rule_group_name
  description = "dev ALB Rule Group"
  capacity    = 1500

  scope = "REGIONAL"

  rule {
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Allow-ALB-Portal-Web"
      sampled_requests_enabled   = true
    }
    name     = "Allow-ALB-Portal-Web"
    priority = 0
    action {
      allow {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = var.portal_web_search_string
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
  }
  rule {
    name     = "Allow-Identity-Web"
    priority = 1
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Allow-Identity-Web"
      sampled_requests_enabled   = true
    }
    action {
      allow {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = var.identity_search_string
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
  }
  rule {
    name     = "Allow-Custom-Forms"
    priority = 2
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Allow-Custom-Forms"
      sampled_requests_enabled   = true
    }
    action {
      allow {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = var.custom_forms_search_string
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
  }
  rule {
    name     = "Allow-ALB-Identity-RP"
    priority = 3
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Allow-ALB-Identity-RP"
      sampled_requests_enabled   = true
    }
    action {
      allow {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = var.identity_rp_search_string
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
  }
  rule {
    name     = "Allow-ALB-Forms-RP"
    priority = 4
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Allow-ALB-Forms-RP"
      sampled_requests_enabled   = true
    }
    action {
      allow {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = var.forms_rp_search_string
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
  }
  rule {
    name     = "Allow-Portal-RP"
    priority = 5
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Allow-Portal-RP"
      sampled_requests_enabled   = true
    }
    action {
      allow {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "host"
          }
        }
        positional_constraint = "EXACTLY"
        search_string         = var.portal_rp_search_string
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
  }
  rule {
    name     = "ALB-CDN-Rule"
    priority = 6
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ALB-CDN-Rule"
      sampled_requests_enabled   = true
    }
    action {
      block {}
    }
    statement {
      not_statement {
        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "x-custom-header"
              }
            }
            positional_constraint = "EXACTLY"
            search_string         = "random-value-123456"
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ALB-Rule-Group"
    sampled_requests_enabled   = true
  }
}



resource "aws_wafv2_web_acl_association" "example_acl_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.rp_web_acl.arn
}
