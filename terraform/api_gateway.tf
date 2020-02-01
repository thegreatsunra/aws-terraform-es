resource "aws_api_gateway_rest_api" "searchApi" {
	name        = "searchApi"
	description = "API for searching movies tutorial"
}

resource "aws_api_gateway_deployment" "searchApiDeployment" {
	depends_on = [aws_api_gateway_integration.searchAPIIntegration]
	rest_api_id = aws_api_gateway_rest_api.searchApi.id
	stage_name  = "searchApiTest"
}

resource "aws_api_gateway_gateway_response" "searchApiResponse" {
	rest_api_id   = aws_api_gateway_rest_api.searchApi.id
	response_type = "DEFAULT_4XX"
	response_templates  = {
		"application/json" = "{\"message\":$context.error.messageString}"
	}
}

resource "aws_api_gateway_resource" "searchApiResource" {
	rest_api_id = aws_api_gateway_rest_api.searchApi.id
	parent_id   = aws_api_gateway_rest_api.searchApi.root_resource_id
	path_part   = "search"
}

resource "aws_api_gateway_method" "searchApiGetMethod" {
	rest_api_id   = aws_api_gateway_rest_api.searchApi.id
	resource_id   = aws_api_gateway_resource.searchApiResource.id
	http_method   = "GET"
	authorization = "NONE"

	request_parameters = {
		"method.request.querystring.q" = true
	}
}

resource "aws_api_gateway_method_response" "searchApiGetMethodResponse" {
	rest_api_id = aws_api_gateway_rest_api.searchApi.id
	resource_id = aws_api_gateway_resource.searchApiResource.id
	http_method = aws_api_gateway_method.searchApiGetMethod.http_method
	status_code = "200"
	response_parameters = {
		"method.response.header.Access-Control-Allow-Methods" = true
		"method.response.header.Access-Control-Allow-Headers" = true
		"method.response.header.Access-Control-Allow-Origin" = true
	}
}

resource "aws_api_gateway_method" "searchApiOptionsMethod" {
	rest_api_id   = aws_api_gateway_rest_api.searchApi.id
	resource_id   = aws_api_gateway_resource.searchApiResource.id
	http_method   = "OPTIONS"
	authorization = "NONE"
}

resource "aws_api_gateway_method_response" "searchApiOptionsMethodResponse" {
	rest_api_id = aws_api_gateway_rest_api.searchApi.id
	resource_id = aws_api_gateway_resource.searchApiResource.id
	http_method = aws_api_gateway_method.searchApiOptionsMethod.http_method
	status_code = "200"
	response_parameters = {
		"method.response.header.Access-Control-Allow-Methods" = true
		"method.response.header.Access-Control-Allow-Headers" = true
		"method.response.header.Access-Control-Allow-Origin" = true
	}
}

resource "aws_api_gateway_integration" "searchApiOptionsIntegration" {
	rest_api_id = aws_api_gateway_rest_api.searchApi.id
	resource_id = aws_api_gateway_resource.searchApiResource.id
	http_method = aws_api_gateway_method.searchApiOptionsMethod.http_method
	type        = "MOCK"

	request_templates = {
		"application/json" = <<EOF
{
	"statusCode": 200
}
EOF
	}
}

## LAMBDA ##

resource "aws_api_gateway_integration" "searchAPIIntegration" {
	rest_api_id             = aws_api_gateway_rest_api.searchApi.id
	resource_id             = aws_api_gateway_resource.searchApiResource.id
	http_method             = aws_api_gateway_method.searchApiGetMethod.http_method
	integration_http_method = "POST"
	type                    = "AWS_PROXY"
	uri                     = aws_lambda_function.searchFunction.invoke_arn
}

resource "aws_lambda_permission" "searchFunctionPermission" {
	statement_id  = "AllowExecutionFromAPIGateway"
	action        = "lambda:InvokeFunction"
	function_name = aws_lambda_function.searchFunction.function_name
	principal     = "apigateway.amazonaws.com"

	# More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
	source_arn = "arn:aws:execute-api:${var.awsRegion}:${var.awsAccountId}:${aws_api_gateway_rest_api.searchApi.id}/*/${aws_api_gateway_method.searchApiGetMethod.http_method}${aws_api_gateway_resource.searchApiResource.path}"
}

data "archive_file" "searchFunctionArchive" {
	type = "zip"
	source_dir = "${path.module}/lambda/searchFunction/."
	output_path = "${path.module}/lambda/searchFunction.zip"
}

resource "aws_lambda_function" "searchFunction" {
	filename      = data.archive_file.searchFunctionArchive.output_path
	publish       = true
	function_name = "searchFunction"
	role          = aws_iam_role.searchFunctionRole.arn
	handler       = "index.lambdaHandler"
	runtime       = "nodejs10.x"
	memory_size   = 256
	timeout       = 60
	source_code_hash = filebase64sha256(data.archive_file.searchFunctionArchive.output_path)
}

# IAM
resource "aws_iam_role" "searchFunctionRole" {
	name = "searchFunctionRole"
	assume_role_policy = data.template_file.iamSearchFunctionPolicyTemplate.rendered
}

resource "aws_iam_role_policy_attachment" "searchFunctionRoleLogPolicyAttachment" {
	role       = aws_iam_role.searchFunctionRole.name
	policy_arn = aws_iam_policy.iamLogPolicy.arn
}

resource "aws_iam_role_policy_attachment" "searchFunctionRoleElasticSearchPolicyAttachment" {
	role       = aws_iam_role.searchFunctionRole.name
	policy_arn = aws_iam_policy.iamElasticSearchPolicy.arn
}

resource "aws_iam_policy" "iamLogPolicy" {
	name        = "iamLogPolicy"
	policy = data.template_file.iamLogPolicyTemplate.rendered
}

resource "aws_iam_policy" "iamElasticSearchPolicy" {
	name        = "iamElasticSearchPolicy"
	policy = data.template_file.iamElasticSearchPolicyTemplate.rendered
}

data "template_file" "iamSearchFunctionPolicyTemplate" {
	template = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "lambda.amazonaws.com"
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF
}

data "template_file" "iamLogPolicyTemplate" {
	template = <<EOF
{
	"Version": "2012-10-17",
	"Statement": {
		"Effect": "Allow",
		"Action": [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:DescribeLogGroups",
			"logs:DescribeLogStreams",
			"logs:PutLogEvents",
			"logs:GetLogEvents",
			"logs:FilterLogEvents"
		],
			"Resource": "arn:aws:logs:*:*:*"
	}
}
EOF
}

data "template_file" "iamElasticSearchPolicyTemplate" {
	template = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "es:*",
			"Effect": "Allow",
			"Resource": "arn:aws:es:${var.awsRegion}:${var.awsAccountId}:domain/${var.esDomain}/*"
		}
	]
}
EOF
}
