terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Internet Gateway
resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gateway.id
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for Lambda (allowing HTTPS traffic)
resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Action"   = "sts:AssumeRole"
        "Effect"   = "Allow"
        "Principal" = {
          "Service" = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for logging
resource "aws_iam_policy" "lambda_logging" {
  name   = "LambdaLoggingPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_logging_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Archive file for Lambda function
data "archive_file" "lambda_arch" {
  type        = "zip"
  source_dir  = "C:\\Users\\riosm\\Desktop\\Terraform Project\\Project(Lambda function)(3)\\App"
  output_path = "C:\\Users\\riosm\\Desktop\\Terraform Project\\Project(Lambda function)(3)\\App\\lambdaFunc.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda_func" {
  function_name    = "lambda_func"
  filename         = data.archive_file.lambda_arch.output_path
  role             = aws_iam_role.lambda_role.arn
  handler          = "todolist.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_arch.output_base64sha256
  timeout          = 20
  depends_on       = [aws_iam_role_policy_attachment.lambda_logging_attach]
}

#Api Gateway
resource "aws_api_gateway_rest_api" "RestAPI" {
  name = "ToDoListAPI"
  description = "API for managing tasks"
}

#Root Menu Method (δεν χρειάζεται resource λόγω της χρήσης του root_resource)
resource "aws_api_gateway_method" "RootGetMethod" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_rest_api.RestAPI.root_resource_id
  http_method = "GET"
  authorization = "NONE"
}

#Root Menu Integration
resource "aws_api_gateway_integration" "RootGetIntegration" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_rest_api.RestAPI.root_resource_id
  http_method = aws_api_gateway_method.RootGetMethod.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_func.invoke_arn
}

#Resource for /task(Add/Delete Task)
resource "aws_api_gateway_resource" "AddDelRes" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  parent_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  path_part = "tasks"
}

#Method for /task(Add)
resource "aws_api_gateway_method" "AddMethod" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_resource.AddDelRes.id
  http_method = "POST"
  authorization = "NONE"
}

#Integration for /task(Add)
resource "aws_api_gateway_integration" "AddInteg" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_resource.AddDelRes.id
  http_method = aws_api_gateway_method.AddMethod.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_func.invoke_arn
}

#Method for /task(Delete)
resource "aws_api_gateway_method" "DelMethod" {
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  resource_id   = aws_api_gateway_resource.AddDelRes.id
  http_method   = "DELETE"
  authorization = "NONE"
}

#Integration for task(Delete)
resource "aws_api_gateway_integration" "DelInteg" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_resource.AddDelRes.id
  http_method = aws_api_gateway_method.DelMethod.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri  = aws_lambda_function.lambda_func.invoke_arn
}

# Resource for /tasks (List all tasks)
resource "aws_api_gateway_resource" "ListRes" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  parent_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  path_part   = "tasks"
}

#Method for /tasks (List all tasks)
resource "aws_api_gateway_method" "ListMethod" {
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  resource_id   = aws_api_gateway_resource.ListRes.id
  http_method   = "GET"
  authorization = "NONE"
}

#Integration for /tasks (List all tasks)
resource "aws_api_gateway_integration" "ListInteg" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_resource.ListRes.id
  http_method = aws_api_gateway_method.ListMethod.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri  = aws_lambda_function.lambda_func.invoke_arn
}

# Resource for /help (Display API usage information)
resource "aws_api_gateway_resource" "helpRes" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  parent_id   = aws_api_gateway_rest_api.RestAPI.root_resource_id
  path_part   = "help"
}

#Method for /help (Display API usage information)
resource "aws_api_gateway_method" "help_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  resource_id   = aws_api_gateway_resource.helpRes.id
  http_method   = "GET"
  authorization = "NONE"
}

#Integration for /help(Display API usage information)
resource "aws_api_gateway_integration" "helpInteg" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  resource_id = aws_api_gateway_resource.helpRes.id
  http_method = aws_api_gateway_method.help_get_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri  = aws_lambda_function.lambda_func.invoke_arn
}

# Deployment for the API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  depends_on  = [
    aws_api_gateway_integration.RootGetIntegration,
    aws_api_gateway_integration.AddInteg,
    aws_api_gateway_integration.DelInteg,
    aws_api_gateway_integration.ListInteg,
    aws_api_gateway_integration.helpInteg
  ]
}

#Stage for the API
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.RestAPI.id
  stage_name    = "v1"

}

# Lambda permission for API Gateway to invoke
resource "aws_lambda_permission" "lambda_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/*"
}

#IAM Policy
resource "aws_iam_policy" "api_access_policy" {
  name        = "APIGatewayPublicAccessPolicy"
  description = "Policy to allow public access to specific API Gateway resources"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "execute-api:Invoke",
        "Resource": [
          "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*"
        ]
      }
    ]
  })
}

#IAM Role
resource "aws_iam_role" "api_access_role" {
  name               = "APIExecutionRole"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "apigateway.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}


# Resource Policy for API Gateway to allow public access
resource "aws_api_gateway_rest_api_policy" "api_gateway_policy" {
  rest_api_id = aws_api_gateway_rest_api.RestAPI.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*"
      }
    ]
  })
}












