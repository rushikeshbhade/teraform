module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "6.4.0"

  name            = "lambda-role-exce"
  use_name_prefix = false
  trust_policy_permissions = {
    LambdaTrust = {
      actions = ["sts:AssumeRole"]

      principals = [{
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }]
    }
  }

  policies = {
    admin = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
}
