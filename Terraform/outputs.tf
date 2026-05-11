output "document_store_bucket" {
  value       = aws_s3_bucket.document_store.bucket
  description = "Document store S3 bucket name"
}

output "intermediate_bucket" {
  value       = aws_s3_bucket.intermediate.bucket
  description = "Intermediate S3 bucket name"
}

output "opensearch_endpoint" {
  value       = aws_opensearch_domain.search.endpoint
  description = "OpenSearch endpoint"
}

output "api_invoke_url" {
  value       = aws_apigatewayv2_api.search_api.api_endpoint
  description = "Base URL for the search API"
}
