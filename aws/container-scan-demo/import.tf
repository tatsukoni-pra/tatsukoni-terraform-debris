import {
  to = aws_s3_bucket.container_scan_demo
  id = "tatsukoni-pra-container-scan-demo"
}

import {
  to = aws_s3_bucket_server_side_encryption_configuration.container_scan_demo
  id = "tatsukoni-pra-container-scan-demo"
}

import {
  to = aws_s3_bucket_public_access_block.container_scan_demo
  id = "tatsukoni-pra-container-scan-demo"
}

import {
  to = aws_s3_bucket_notification.container_scan_demo
  id = "tatsukoni-pra-container-scan-demo"
}

# EventBridge Rule
import {
  to = aws_cloudwatch_event_rule.container_scan_demo
  id = "EventRule-ContainerScanDemo"
}

import {
  to = aws_cloudwatch_event_target.container_scan_demo
  id = "EventRule-ContainerScanDemo/6a9ed01f-79d9-4d7c-b65f-79bb0a623a69"
}

# IAM Role for EventBridge
import {
  to = aws_iam_role.eventbridge_invoke_stepfunctions
  id = "Amazon_EventBridge_Invoke_StepFunctions_1822831248"
}

import {
  to = aws_iam_policy.eventbridge_invoke_stepfunctions
  id = "arn:aws:iam::083636136646:policy/service-role/Amazon_EventBridge_Invoke_StepFunctions_1822831248"
}

import {
  to = aws_iam_role_policy_attachment.eventbridge_invoke_stepfunctions
  id = "Amazon_EventBridge_Invoke_StepFunctions_1822831248/arn:aws:iam::083636136646:policy/service-role/Amazon_EventBridge_Invoke_StepFunctions_1822831248"
}

# IAM Role for StepFunctions
import {
  to = aws_iam_role.stepfunctions_container_scan_demo
  id = "SfnContainerScanDemo"
}

import {
  to = aws_iam_role_policy.stepfunctions_container_scan_demo
  id = "SfnContainerScanDemo:SfnContainerScanDemoPolicy"
}

# StepFunctions State Machine
import {
  to = aws_sfn_state_machine.container_scan_demo
  id = "arn:aws:states:ap-northeast-1:083636136646:stateMachine:SfnContainerScanDemo"
}
