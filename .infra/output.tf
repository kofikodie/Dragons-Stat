output "dev_api_url" {
  value = aws_api_gateway_deployment.dev_deployment.invoke_url
}

output "gw_id" {
  value = aws_api_gateway_rest_api.dragon_api.id
}

output "gw_root_id" {
  value = aws_api_gateway_rest_api.dragon_api.root_resource_id
}

output "lambda_role_arn" {
  value = aws_iam_role.iam_for_lambda.arn
}


output "execution_role_arn" {
  value = aws_api_gateway_rest_api.dragon_api.execution_arn
}
