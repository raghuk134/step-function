resource "aws_sfn_state_machine" "step_function" {
  name     = "MyStepFunction"
  role_arn   = "arn:aws:iam::536569225538:role/step_function_role"
  definition = <<EOF
{
  "Comment": "An example of Step Functions State Machine",
  "StartAt": "ParallelExecution",
  "TimeoutSeconds": 300,
  "States": {
    "ParallelExecution": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "Lambda1",
          "States": {
            "Lambda1": {
              "Type": "Task",
              "Resource": "arn:aws:lambda:us-east-1:536569225538:function:function1",
              "Next": "Wait"
            },
            "Wait": {
              "Type": "Wait",
              "Seconds": 5,
              "Next": "SQS SendMessage"
            },
            "SQS SendMessage": {
              "Type": "Task",
              "Resource": "arn:aws:states:::sqs:sendMessage",
              "Parameters": {
                "MessageBody.$": "$",
                "QueueUrl": "https://sqs.us-east-1.amazonaws.com/536569225538/testQueue"
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "Lambda2",
          "States": {
            "Lambda2": {
              "Type": "Task",
              "Resource": "arn:aws:lambda:us-east-1:536569225538:function:function2",
              "End": true
            }
          }
        },
        {
          "StartAt": "SNS Publish",
          "States": {
            "SNS Publish": {
              "Type": "Task",
              "Resource": "arn:aws:states:::sns:publish",
              "Parameters": {
                "Message.$": "$",
                "TopicArn": "arn:aws:sns:us-east-1:536569225538:testTopic"
              },
              "Next": "Lambda3"
            },
            "Lambda3": {
              "Type": "Task",
              "Resource": "arn:aws:lambda:us-east-1:536569225538:function:function3",
              "End": true
            }
          }
        },
        {
          "StartAt": "CreateBucket",
          "States": {
            "CreateBucket": {
              "Type": "Task",
              "Resource": "arn:aws:states:::aws-sdk:s3:createBucket",
              "Parameters": {
                  "Bucket": "new-sfn-bucket-btc0-beyondthecloud"
              },
              "End": true
            }
          }
        }
      ],
      "End": true
    }
  }
}
EOF

}
