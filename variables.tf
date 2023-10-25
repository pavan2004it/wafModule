variable "alb_arn" {
  type = string
}
variable "waf_description" {
  type = string
}
variable "rule_group_metric_name" {
  type = string
}
variable "rule_group_scope" {
  type = string
}
variable "rule_group_capacity" {
  type = number
}
variable "waf_scope" {
  type = string
}
variable "waf_rule_name" {
  type = string
}
variable "waf_name" {
  type = string
}
variable "waf_metric_name" {
  type = string
}

variable "rule_group_name" {
  type = string
}

variable "waf_rules" {
  description = "List of WAF rules"
  type = list(object({
    visibility_config_cloudwatch_metrics_enabled = bool
    visibility_config_metric_name                = string
    visibility_config_sampled_requests_enabled   = bool
    name                                         = string
    priority                                     = number
    action                                       = string # "allow", "block", "count"
    byte_match_search_string                     = string
    byte_match_positional_constraint             = string
    byte_match_header_name                       = string
    text_transformation_priority                 = number
    text_transformation_type                     = string
  }))
}

