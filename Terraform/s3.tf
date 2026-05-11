resource "aws_s3_bucket" "document_store" {
  bucket = var.document_store_bucket_name

  tags = merge(var.tags, {
    Name = "document-store"
  })
}

resource "aws_s3_bucket" "intermediate" {
  bucket = var.intermediate_bucket_name

  tags = merge(var.tags, {
    Name = "intermediate-store"
  })
}

# Allow S3 to invoke Lambda (pdftotxt)
resource "aws_lambda_permission" "s3_invoke_pdftotxt" {
  statement_id  = "AllowS3InvokePdftotxt"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdftotxt.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.document_store.arn
}

resource "aws_s3_bucket_notification" "document_store_notifications" {
  bucket = aws_s3_bucket.document_store.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.pdftotxt.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke_pdftotxt]
}

# Allow S3 to invoke Lambda (upload-to-search)
resource "aws_lambda_permission" "s3_invoke_upload_to_search" {
  statement_id  = "AllowS3InvokeUploadToSearch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_to_search.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.intermediate.arn
}

resource "aws_s3_bucket_notification" "intermediate_notifications" {
  bucket = aws_s3_bucket.intermediate.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.upload_to_search.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke_upload_to_search]
}
