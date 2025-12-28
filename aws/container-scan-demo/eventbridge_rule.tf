resource "aws_cloudwatch_event_rule" "container_scan_demo" {
  name        = "EventRule-ContainerScanDemo"
  description = "EventRule-ContainerScanDemo"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = ["tatsukoni-pra-container-scan-demo"]
      }
      object = {
        key = [{
          suffix = "/suppression_detail.json"
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "container_scan_demo" {
  rule      = aws_cloudwatch_event_rule.container_scan_demo.name
  target_id = "6a9ed01f-79d9-4d7c-b65f-79bb0a623a69"
  arn       = aws_sfn_state_machine.container_scan_demo.arn
  role_arn  = aws_iam_role.eventbridge_invoke_stepfunctions.arn
}
