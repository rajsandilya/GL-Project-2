variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID where OpenSearch will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs for OpenSearch and API Gateway/Lambda networking if needed"
  type        = list(string)
}

variable "document_store_bucket_name" {
  description = "S3 bucket name for original PDF documents"
  type        = string
  default     = "init-docu-store-09052026093305"
}

variable "intermediate_bucket_name" {
  description = "S3 bucket name for intermediate text files"
  type        = string
  default     = "inter-docu-store-09052026093405"
}

variable "opensearch_domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
  default     = "search-engine-domain"
}

variable "opensearch_master_user" {
  description = "Master username for OpenSearch fine-grained access control"
  type        = string
  default     = "master-user"
}

variable "opensearch_master_password" {
  description = "Master password for OpenSearch fine-grained access control"
  type        = string
  sensitive   = true
}

variable "lambda_pdftotxt_zip" {
  description = "Path to pdftotxt Lambda ZIP file"
  type        = string
  default     = "lambda_placeholders/PDFtoTXT.zip"
}

variable "lambda_upload_to_search_zip" {
  description = "Path to upload-to-search Lambda ZIP file"
  type        = string
  default     = "lambda_placeholders/Upload_to_search.zip"
}

variable "lambda_search_gateway_zip" {
  description = "Path to search-gateway Lambda ZIP file"
  type        = string
  default     = "lambda_placeholders/Search_gateway.zip"
}

variable "lambda_search_function_zip" {
  description = "Path to searchFunction Lambda ZIP file"
  type        = string
  default     = "lambda_placeholders/Search_function.zip"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project = "SearchEngine"
    Owner   = "Raj Ponukumati"
  }
}
