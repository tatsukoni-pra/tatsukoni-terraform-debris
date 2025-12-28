# resource "aws_sfn_state_machine" "container_scan_demo" {
#   name     = "SfnContainerScanDemo"
#   role_arn = aws_iam_role.stepfunctions_container_scan_demo.arn

#   definition = jsonencode({
#     Comment   = "A description of my state machine"
#     StartAt   = "GetObject"
#     QueryLanguage = "JSONata"
#     States = {
#       GetObject = {
#         Type = "Task"
#         Arguments = {
#           Bucket = "{% $states.input.detail.bucket.name %}"
#           Key    = "{% $states.input.detail.object.key %}"
#         }
#         Resource = "arn:aws:states:::aws-sdk:s3:getObject"
#         Next     = "CreateFilter"
#         Assign = {
#           suppressionDetail = "{% $parse($states.result.Body) %}"
#         }
#       }
#       CreateFilter = {
#         Type = "Task"
#         Arguments = {
#           Action = "SUPPRESS"
#           FilterCriteria = {
#             EcrImageRepositoryName = [{
#               Comparison = "EQUALS"
#               Value      = "{% $suppressionDetail.image_name %}"
#             }]
#             VulnerabilityId = [{
#               Comparison = "EQUALS"
#               Value      = "{% $suppressionDetail.cve %}"
#             }]
#           }
#           Name        = "{% $suppressionDetail.image_name & '-' & $suppressionDetail.cve %}"
#           Description = "{% '担当チーム - ' & $suppressionDetail.team & ' / 抑制実施日 - ' & $suppressionDetail.created_at & ' / 抑制理由 - ' & $suppressionDetail.reason & ' / 抑制解除タイミング - ' & $suppressionDetail.lift_condition %}"
#         }
#         Resource = "arn:aws:states:::aws-sdk:inspector2:createFilter"
#         End      = true
#       }
#     }
#   })

#   logging_configuration {
#     level                  = "OFF"
#     include_execution_data = false
#   }

#   tracing_configuration {
#     enabled = false
#   }
# }
