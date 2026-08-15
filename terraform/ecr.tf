resource "aws_ecr_repository" "flask_app" {
  name                 = "${var.environment}-flask-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.environment}-flask-app-repo"
  }
}

# Keep the repository clean by Automatically remove images that are older than 30 days.
resource "aws_ecr_lifecycle_policy" "flask_app_policy" {
  repository = aws_ecr_repository.flask_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Automatically remove images that are older than 30 days."
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}