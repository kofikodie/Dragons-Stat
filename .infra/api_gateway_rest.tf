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

resource "aws_api_gateway_integration" "dragon_api_integration" {
  http_method = aws_api_gateway_method.dragon_api_method_get.http_method
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

resource "aws_api_gateway_integration_response" "dragon_integration_response_get" {
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  http_method = aws_api_gateway_method.dragon_api_method_get.http_method
  status_code = aws_api_gateway_method_response.dragon_response_get_200.status_code

  response_templates = {
    "application/json" = <<REQUEST_TEMPLATE
      #if($input.params("family") == "green") 
      {
        "description_str":"Xanya is the fire tribe's banished general. She broke ranks and has been wandering ever since.",
        "dragon_name_str":"Xanya",
        "family_str":"red",
        "location_city_str":"las vegas",
        "location_country_str":"usa",
        "location_neighborhood_str":"e clark ave",
        "location_state_str":"nevada"
      }
      #elseif($input.params("family") == "blue") 
      {
        "description_str":"Shadown is the water tribe's main general. He commands the blue dragons.",
        "dragon_name_str":"Shadown",
        "family_str":"blue",
        "location_city_str":"las vegas",
        "location_country_str":"usa",
        "location_neighborhood_str":"e clark ave",
        "location_state_str":"nevada"
      }
      #elseif($input.params("family") == "black") 
      {
        "description_str":"Tawny is the earth tribe's main general. He commands the black dragons.",
        "dragon_name_str":"Tawny",
        "family_str":"black",
        "location_city_str":"las vegas",
        "location_country_str":"usa",
        "location_neighborhood_str":"e clark ave",
        "location_state_str":"nevada"
      },
      {
        "description_str":"Eislex flies with the fire sprites. He protects them and is their guardian.",
        "dragon_name_str":"Eislex",
        "family_str":"red",
        "location_city_str":"st. cloud",
        "location_country_str":"usa",
        "location_neighborhood_str":"breckenridge ave",
        "location_state_str":"minnesota"
      }
      #else
      {
        "description_str":"",
        "dragon_name_str":"",
        "family_str":"",
        "location_city_str":"",
        "location_country_str":"",
        "location_neighborhood_str":"",
        "location_state_str":""
      }
      #end
REQUEST_TEMPLATE
  }
}

resource "aws_api_gateway_method_response" "dragon_response_get_200" {
  rest_api_id = aws_api_gateway_rest_api.dragon_api.id
  resource_id = aws_api_gateway_resource.dragons_api_resource.id
  http_method = aws_api_gateway_method.dragon_api_method_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_method" "dragon_api_method_post" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id   = aws_api_gateway_rest_api.dragon_api.id
}


resource "aws_api_gateway_integration" "dragon_api_integration_post" {
  http_method             = aws_api_gateway_method.dragon_api_method_post.http_method
  resource_id             = aws_api_gateway_resource.dragons_api_resource.id
  rest_api_id             = aws_api_gateway_rest_api.dragon_api.id
  type                    = "MOCK"
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
  name         = "user"
  description  = "a JSON schema"
  content_type = "application/json"

  schema = <<EOF
{
  "type": "object"
}
EOF
}
