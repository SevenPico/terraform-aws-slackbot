variable "sns_pub_principals" {
  type    = map(list(string))
  default = {}
}

variable "sns_sub_principals" {
  type    = map(list(string))
  default = {}
}

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}

variable "slack_channels" {
  type        = map(string)
  description = "Map topic to slack channel id"
}

variable "slack_token_secret_arn" {
  type    = string
}

variable "slack_token_secret_kms_key_arn" {
  type    = string
  default = ""
}
