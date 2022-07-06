resource "aws_iam_role" "lambda_role" {
  name = "${local.name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:*",
            "states:*"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameters",
            "ssm:GetParameter",
            "ssm:GetParametersByPath"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeNetworkInterfaces",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeInstances",
            "ec2:AttachNetworkInterface",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "lambda:InvokeFunction",
            "lambda:InvokeAsync"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        },
        {
          "Sid": "ListAndDescribe",
          "Effect": "Allow",
          "Action": [
            "dynamodb:List*",
            "dynamodb:DescribeReservedCapacity*",
            "dynamodb:DescribeLimits",
            "dynamodb:DescribeTimeToLive"
          ],
          "Resource": "*"
        },
        {
          "Sid": "SpecificTable",
          "Effect": "Allow",
          "Action": [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeStream",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:BatchWrite*",
            "dynamodb:CreateTable",
            "dynamodb:Delete*",
            "dynamodb:Update*",
            "dynamodb:PutItem"
          ],
          "Resource": [
            "arn:aws:dynamodb:*:*:table/*",
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ssm:DescribeParameters"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "ssm:GetParameters"
          ],
          "Resource": "arn:aws:ssm:*:*:parameter/${local.name}*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

######## hello
resource "aws_lambda_function" "hello" {
  function_name    = "${local.name}-hello"
  role             = aws_iam_role.lambda_role.arn
  memory_size      = 512
  timeout          = 120

  handler       = null
  runtime       = null
  package_type  = "Image"
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/lambdas-common:latest"

  image_config {
    command = [ "hello.handler" ]
  }

  environment {
    variables = {
      ENV         = local.name

    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.role_policy_attachment,
    aws_cloudwatch_log_group.hello,
  ]

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "hello" {
  name              = "/aws/lambda/${local.name}-hello"
  retention_in_days = 14
}

resource "aws_lambda_permission" "combine_audio_files_execution" {
  function_name = aws_lambda_function.hello.function_name

  statement_id = "APIGatewayExecution"
  action       = "lambda:InvokeFunction"
  principal    = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*/*"
}

