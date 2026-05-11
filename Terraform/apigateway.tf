resource "aws_apigatewayv2_api" "search_api" {
  name          = "search-api"
  protocol_type = "HTTP"

  tags = var.tags
}

# Integration for search-gateway (root /)
resource "aws_apigatewayv2_integration" "search_gateway_integration" {
  api_id                 = aws_apigatewayv2_api.search_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.search_gateway.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Integration for searchFunction (/search)
resource "aws_apigatewayv2_integration" "search_function_integration" {
  api_id                 = aws_apigatewayv2_api.search_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.search_function.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "root_route" {
  api_id    = aws_apigatewayv2_api.search_api.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.search_gateway_integration.id}"
}

resource "aws_apigatewayv2_route" "search_route" {
  api_id    = aws_apigatewayv2_api.search_api.id
  route_key = "ANY /search"
  target    = "integrations/${aws_apigatewayv2_integration.search_function_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.search_api.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

# Allow API Gateway to invoke Lambdas
resource "aws_lambda_permission" "apigw_invoke_search_gateway" {
  statement_id  = "AllowAPIGWInvokeSearchGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.search_gateway.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.search_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_invoke_search_function" {
  statement_id  = "AllowAPIGWInvokeSearchFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.search_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.search_api.execution_arn}/*/*"
}
