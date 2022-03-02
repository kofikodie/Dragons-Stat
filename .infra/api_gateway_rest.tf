locals {
  s3_bucket     = var.S3_BUCKET_NAME
  s3_key        = var.S3_BUCKET_KEY
  function_name = "dragon-ws-dev-dragon_ws"
  version       = "19"
}

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

resource "aws_api_gateway_method" "dragon_api_method_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.dragon_api.id
}

module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.dragon_api.id
  api_resource_id = aws_api_gateway_rest_api.dragon_api.root_resource_id
}

resource "aws_lambda_alias" "dragon_api_alias" {
  name             = "dragon_api_alias"
  function_name    = local.function_name
  function_version = local.version
}

resource "aws_api_gateway_integration" "dragon_api_integration" {
  http_method             = aws_api_gateway_method.dragon_api_method_get.http_method
  integration_http_method = "GET"
  resource_id             = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id             = aws_api_gateway_rest_api.dragon_api.id
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_alias.dragon_api_alias.invoke_arn #"arn:aws:apigateway:${var.AWS_DEFAULT_REGION}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.AWS_DEFAULT_REGION}:${var.AWS_ACCOUNT_ID}:function:${local.function_name}/invocations"
}

### Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.dragon_api.execution_arn}/*/*"
}

resource "aws_api_gateway_method_response" "dragon_response_get_200" {
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  http_method = aws_api_gateway_method.dragon_api_method_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_method" "dragon_api_method_post" {
  authorization        = "NONE"
  http_method          = "POST"
  resource_id          = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id          = aws_api_gateway_rest_api.dragon_api.id
  request_validator_id = aws_api_gateway_request_validator.dragon_post_request_validator.id
  request_models = {
    "application/json" = "${aws_api_gateway_model.dragon_model.name}"
  }
}


resource "aws_api_gateway_integration" "dragon_api_integration_post" {
  http_method = aws_api_gateway_method.dragon_api_method_post.http_method
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        "statusCode" = 200
      }
    )
  }
}

resource "aws_api_gateway_method_response" "dragon_response_post_200" {
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  http_method = aws_api_gateway_method.dragon_api_method_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "dragon_integration_response_post" {
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  http_method = aws_api_gateway_method.dragon_api_method_post.http_method
  status_code = aws_api_gateway_method_response.dragon_response_post_200.status_code

  response_templates = {
    "application/json" = <<REQUEST_TEMPLATE
      {
        "statusCode" = 200
      }
    REQUEST_TEMPLATE
  }
}

resource "aws_api_gateway_model" "dragon_model" {
  rest_api_id  = aws_api_gateway_rest_api.dragon_api.id
  name         = "dragon"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
  {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "Dragon",
    "type": "object",
    "properties": {
      "dragonName": {
        "type": "string"
      },
      "description": {
        "type": "string"
      },
      "family": {
        "type": "string"
      },
      "city": {
        "type": "string"
      },
      "country": {
        "type": "string"
      },
      "state": {
        "type": "string"
      },
      "neighborhood": {
        "type": "string"
      },
      "reportingPhoneNumber": {
        "type": "string"
      },
      "confirmationRequired": {
        "type": "boolean"
      }
    }
  }
  EOF
}

resource "aws_api_gateway_request_validator" "dragon_post_request_validator" {
  rest_api_id                 = aws_api_gateway_rest_api.dragon_api.id
  name                        = "dragon_post_request_validator"
  validate_request_body       = true
  validate_request_parameters = false
}

resource "aws_api_gateway_deployment" "dev_deployment" {
  depends_on = [
    aws_api_gateway_method.dragon_api_method_get,
    aws_api_gateway_method.dragon_api_method_post
  ]
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  stage_name  = "dev_api"
}
