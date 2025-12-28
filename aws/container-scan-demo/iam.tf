# EventBridge role to invoke StepFunctions
resource "aws_iam_role" "eventbridge_invoke_stepfunctions" {
  name = "Amazon_EventBridge_Invoke_StepFunctions_1822831248"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_invoke_stepfunctions" {
  name = "Amazon_EventBridge_Invoke_StepFunctions_1822831248"
  path = "/service-role/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "states:StartExecution"
        ]
        Resource = [
          aws_sfn_state_machine.container_scan_demo.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_invoke_stepfunctions" {
  role       = aws_iam_role.eventbridge_invoke_stepfunctions.name
  policy_arn = aws_iam_policy.eventbridge_invoke_stepfunctions.arn
}

# StepFunctions role
resource "aws_iam_role" "stepfunctions_container_scan_demo" {
  name        = "SfnContainerScanDemo"
  description = "Allows Step Functions to access AWS resources on your behalf."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "SfnContainerScanDemo"
  }
}

resource "aws_iam_role_policy" "stepfunctions_container_scan_demo" {
  name = "SfnContainerScanDemoPolicy"
  role = aws_iam_role.stepfunctions_container_scan_demo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Resource = "arn:aws:s3:::tatsukoni-pra-container-scan-demo/*"
      },
      {
        Effect   = "Allow"
        Action   = "inspector2:CreateFilter"
        Resource = "*"
      }
    ]
  })
}
