data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "search-engine-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = var.tags
}

# Basic Lambda + CloudWatch Logs
data "aws_iam_policy_document" "lambda_basic" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_basic" {
  name   = "search-engine-lambda-basic"
  policy = data.aws_iam_policy_document.lambda_basic.json
}

# S3 access for pdftotxt and upload-to-search
data "aws_iam_policy_document" "lambda_s3" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.document_store.arn,
      "${aws_s3_bucket.document_store.arn}/*",
      aws_s3_bucket.intermediate.arn,
      "${aws_s3_bucket.intermediate.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_s3" {
  name   = "search-engine-lambda-s3"
  policy = data.aws_iam_policy_document.lambda_s3.json
}

# OpenSearch access for upload-to-search and searchFunction
data "aws_iam_policy_document" "lambda_opensearch" {
  statement {
    actions = [
      "es:ESHttpGet",
      "es:ESHttpPost",
      "es:ESHttpPut",
      "es:ESHttpDelete"
    ]
    resources = [
      "${aws_opensearch_domain.search.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_opensearch" {
  name   = "search-engine-lambda-opensearch"
  policy = data.aws_iam_policy_document.lambda_opensearch.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_basic.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3.arn
}

resource "aws_iam_role_policy_attachment" "lambda_opensearch_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_opensearch.arn
}
