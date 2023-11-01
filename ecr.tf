# --- ECR ---

resource "aws_ecr_repository" "max-ng" {
  name                 = "max-ng-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "max-ng_repo_url" {
  value = aws_ecr_repository.max-ng.repository_url
}