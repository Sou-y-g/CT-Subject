#################################################
# ECR
#################################################
# ECR作成
resource "aws_ecr_repository" "ecr" {
  name = "nginx"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.tag}-ecr"
  }
}