#################################################
# IAM role
#################################################
# ECSタスク実行ロール
# AssumeRole
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECSTaskExecutionRole
data "aws_iam_policy" "ecs_task_execution_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECSTaskExecutionRoleをECSタスク実行ロールにアタッチ
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_policy.arn
}

# EC2 インスタンスプロファイル
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_ec2_role.name
}

# EC2 IAM Role
resource "aws_iam_role" "ecs_ec2_role" {
  name = "ecs_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# AmazonEC2ContainerServiceforEC2Roleポリシー
data "aws_iam_policy" "ecs_ec2_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# AmazonEC2ContainerServiceforEC2RoleポリシーをEC2用Roleにアタッチ
resource "aws_iam_role_policy_attachment" "ecs_ec2_role_policy_attachment" {
  role       = aws_iam_role.ecs_ec2_role.name
  policy_arn = data.aws_iam_policy.ecs_ec2_role_policy.arn
}