provider "aws" {
  profile = "default"
  region = "us-east-2"
}

data "aws_iam_policy_document" "omopfhir" {
  statement {
    actions = ["ec2:*"]

    resources = ["*"]
    condition {
      test = "StringEquals"
      variable = "ec2:Region"
      values = ["us-east-2"]
    }
  }
  statement {
    actions = ["rds:*"]
    resources = ["arn:aws:rds:us-east-2:*:*"]
  }
  statement {
    actions = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::*:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"]
    condition {
      test = "StringLike" 
      variable = "iam:AWSServiceName"
      values = ["rds.amazonaws.com"]
    }
  }
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:us-east-2:141094345300:secret:omopfhir/db_creds-GbTFQZ"]
  }
}

resource "aws_iam_user_policy" "omopfhir" {
  name = "omopfhir"
  user = aws_iam_user.omopfhir.name

  policy = data.aws_iam_policy_document.omopfhir.json
}

resource "aws_iam_user" "omopfhir" {
  name = "omopfhir"
}

resource "aws_iam_access_key" "omopfhir" {
  user = aws_iam_user.omopfhir.name
}

output "key_fingerprint" {
  value = aws_iam_access_key.omopfhir.key_fingerprint
}

output "secret" {
  value = aws_iam_access_key.omopfhir.secret
}

