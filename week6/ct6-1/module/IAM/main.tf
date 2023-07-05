############################################################
# Roel作成
############################################################
# ssm-roleの作成
resource "aws_iam_role" "ssm-role" {
  name               = "ssm-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

# ssm-roleの信頼ポリシー
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ssm-roleのアイデンティティポリシー
data "aws_iam_policy_document" "ssm-role-policy" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = ["*"]
  }
}

# ssm-policyの作成
resource "aws_iam_policy" "ssm-role-policy" {
  name        = "ssm-role-policy"
  description = "policy for ssm-role"
  policy      = data.aws_iam_policy_document.ssm-role-policy.json
}

# ssm-policy => ssm-role
resource "aws_iam_role_policy_attachment" "ssm-role-policy" {
  role       = aws_iam_role.ssm-role.name
  policy_arn = aws_iam_policy.ssm-role-policy.arn
}

# ssm-role => profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = aws_iam_role.ssm-role.name
}