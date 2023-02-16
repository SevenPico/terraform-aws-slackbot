## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

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
