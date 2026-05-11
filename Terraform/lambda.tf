# Lambda 1: pdftotxt
resource "aws_lambda_function" "pdftotxt" {
  function_name = "pdftotxt"
  role          = aws_iam_role.lambda_role.arn
  handler       = "sample.handler" # adjust if different
  runtime       = local.lambda_runtime
  filename      = var.lambda_pdftotxt_zip
  source_code_hash = filebase64sha256(var.lambda_pdftotxt_zip)

  environment {
    variables = {
      TARGET_BUCKET = aws_s3_bucket.intermediate.bucket
    }
  }

  tags = var.tags
}

# Lambda 2: upload-to-search
resource "aws_lambda_function" "upload_to_search" {
  function_name = "upload-to-search"
  role          = aws_iam_role.lambda_role.arn
  handler       = "sample.handler" # as per doc: sample.py -> handler
  runtime       = local.lambda_runtime
  filename      = var.lambda_upload_to_search_zip
  source_code_hash = filebase64sha256(var.lambda_upload_to_search_zip)

  environment {
    variables = {
      REGION = var.region
      HOST   = aws_opensearch_domain.search.endpoint
    }
  }

  tags = var.tags
}

# Lambda 3: search-gateway
resource "aws_lambda_function" "search_gateway" {
  function_name = "search-gateway"
  role          = aws_iam_role.lambda_role.arn
  handler       = "sample.lambda_handler" # as per doc
  runtime       = local.lambda_runtime
  filename      = var.lambda_search_gateway_zip
  source_code_hash = filebase64sha256(var.lambda_search_gateway_zip)

  environment {
    variables = {
      REGION = var.region
      HOST   = aws_opensearch_domain.search.endpoint
    }
  }

  tags = var.tags
}

# Lambda 4: searchFunction
resource "aws_lambda_function" "search_function" {
  function_name = "searchFunction"
  role          = aws_iam_role.lambda_role.arn
  handler       = "sample.lambda_handler"
  runtime       = local.lambda_runtime
  filename      = var.lambda_search_function_zip
  source_code_hash = filebase64sha256(var.lambda_search_function_zip)

  environment {
    variables = {
      REGION = var.region
      HOST   = aws_opensearch_domain.search.endpoint
    }
  }

  tags = var.tags
}
