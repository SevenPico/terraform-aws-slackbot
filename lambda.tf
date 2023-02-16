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
##  ./lambda.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "sns_topic" {
  source  = "SevenPico/sns/aws"
  version = "2.0.0"
  context = module.context.self

  kms_master_key_id = ""
  pub_principals    = var.sns_pub_principals
  sub_principals    = var.sns_sub_principals
}


# ------------------------------------------------------------------------------
# Slackbot Lambda
# ------------------------------------------------------------------------------
module "lambda" {
  source     = "SevenPicoForks/lambda-function/aws"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["lambda"]

  architectures                       = null
  cloudwatch_event_rules              = {}
  cloudwatch_lambda_insights_enabled  = false
  cloudwatch_logs_kms_key_arn         = null
  cloudwatch_logs_retention_in_days   = var.cloudwatch_log_expiration_days
  cloudwatch_log_subscription_filters = {}
  description                         = "Slackbot"
  event_source_mappings               = {}
  filename                            = data.archive_file.lambda[0].output_path
  function_name                       = module.context.id
  handler                             = "main.lambda_handler"
  ignore_external_function_updates    = false
  image_config                        = {}
  image_uri                           = null
  kms_key_arn                         = ""
  lambda_at_edge                      = false
  layers                              = []
  memory_size                         = 128
  package_type                        = "Zip"
  publish                             = false
  reserved_concurrent_executions      = -1
  role_name                           = "${module.context.id}-role"
  runtime                             = "python3.9"
  s3_bucket                           = null
  s3_key                              = null
  s3_object_version                   = null
  sns_subscriptions                   = {}
  source_code_hash                    = data.archive_file.lambda[0].output_base64sha256
  ssm_parameter_names                 = null
  timeout                             = 60
  tracing_config_mode                 = null
  vpc_config                          = null

  lambda_environment = {
    variables = {
      SLACK_CHANNELS   = join(",", [for topic, id in var.slack_channels : "${topic}=${id}"])
      SLACK_SECRET_ARN = var.slack_token_secret_arn
    }
  }
}

data "archive_file" "lambda" {
  count       = module.context.enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/.build/lambda.zip"
}


# ------------------------------------------------------------------------------
# Lambda SNS Subscription
# ------------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "lambda" {
  count = module.context.enabled ? 1 : 0

  endpoint  = module.lambda.arn
  protocol  = "lambda"
  topic_arn = module.sns_topic.topic_arn
}

resource "aws_lambda_permission" "sns" {
  count = module.context.enabled ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_topic.topic_arn
  statement_id  = "AllowExecutionFromSNS"
}


# ------------------------------------------------------------------------------
# Lambda IAM
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda" {
  count      = module.context.enabled ? 1 : 0
  depends_on = [module.lambda]

  role       = "${module.context.id}-role"
  policy_arn = module.lambda_policy.policy_arn
}

module "lambda_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"
  context = module.context.legacy

  description                   = "Slackbot Lambda Access Policy"
  iam_override_policy_documents = null
  iam_policy_enabled            = true
  iam_policy_id                 = null
  iam_source_json_url           = null
  iam_source_policy_documents   = null

  iam_policy_statements = {
    SecretRead = {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = [var.slack_token_secret_arn]
    }
    KmsDecrypt = {
      effect    = "Allow"
      actions   = ["kms:Decrypt", "kms:DescribeKey"]
      resources = [var.slack_token_secret_kms_key_arn]
    }
  }
}
