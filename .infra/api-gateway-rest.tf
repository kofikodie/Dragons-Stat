resource "aws_api_gateway_rest_api" "dragon_api" {
  name = "dragon_api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "dragons_api_resource" {
  parent_id   = aws_api_gateway_rest_api.dragon_api.root_resource_id
  path_part   = "dragons"
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
}

resource "aws_api_gateway_method" "dragon_api_method" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.dragon_api.id
}


resource "aws_api_gateway_integration" "dragon_api_integration" {
  http_method = aws_api_gateway_method.dragon_api_method.http_method
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "dragon_response_200" {
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  http_method = aws_api_gateway_method.dragon_api_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "dragon_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  http_method = aws_api_gateway_method.dragon_api_method.http_method
  status_code = aws_api_gateway_method_response.dragon_response_200.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_model" "dragon_model" {
  rest_api_id  = aws_api_gateway_rest_api.dragon_api.id
  name         = "user"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
{
  "type": "object"
}
EOF
}
