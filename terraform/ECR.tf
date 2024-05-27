resource "aws_ecr_repository" "ECR-1" {
  name                 = "${var.name}-ecr-backend-image"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "ECR-2" {
  name                 = "${var.name}-ecr-frontend-image"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}