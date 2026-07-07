output "repository_urls" {

  value = {

    for repo, value in aws_ecr_repository.this :

    repo => value.repository_url
  }
}