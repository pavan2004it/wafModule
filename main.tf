resource "aws_wafv2_web_acl" "rp-web-acl" {
  name        = var.waf_name
  description = var.waf_description
  scope       = var.waf_scope

  default_action {
    allow {}
  }
  rule {
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = var.waf_metric_name
      sampled_requests_enabled   = true
    }
    name     = var.waf_rule_name
    priority = 0
    statement {
      rule_group_reference_statement {
        arn = aws_wafv2_rule_group.rp-rg.arn
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.waf_metric_name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_rule_group" "rp-rg" {
  capacity = var.rule_group_capacity
  name     = var.rule_group_name
  scope    = var.rule_group_scope
  dynamic "rule" {
    for_each = var.waf_rules
    content {
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.visibility_config_metric_name
        sampled_requests_enabled   = true
      }
      name = rule.value.name
      priority = rule.value.priority
      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
      }
      statement {
        byte_match_statement {
          field_to_match {
            single_header {
              name = rule.value.byte_match_header_name
            }
          }
          positional_constraint = rule.value.byte_match_positional_constraint
          search_string = rule.value.byte_match_search_string
          text_transformation {
            priority = rule.value.text_transformation_priority
            type     = rule.value.text_transformation_type
          }
        }
      }
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = var.rule_group_metric_name
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "example_acl_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.rp-web-acl.arn
}