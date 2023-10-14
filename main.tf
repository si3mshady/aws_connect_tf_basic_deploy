#Basic setup for AWS Connect

resource "aws_connect_instance" "thecloudshepherd_youtube" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  instance_alias           = "thecloudshepherdyoutube"
  outbound_calls_enabled   = true
}


resource "aws_connect_phone_number" "thecloudshepherd" {
  target_arn   = aws_connect_instance.thecloudshepherd_youtube.arn
  depends_on = [ aws_connect_hours_of_operation.business_hours ]
  country_code = "US"
  type         = "DID"
  tags = {
    "number" = "US"
  }
}

resource "aws_connect_hours_of_operation" "business_hours" {
  instance_id = aws_connect_instance.thecloudshepherd_youtube.id
  name        = "Business Hours"
  description = "Open For Business"
  time_zone   = "CENTRAL"
  config {
    day = "MONDAY"
    end_time {
      hours   = 23
      minutes = 8
    }
    start_time {
      hours   = 8
      minutes = 0
    }
  }
  config {
    day = "TUESDAY"
    end_time {
      hours   = 21
      minutes = 0
    }
    start_time {
      hours   = 9
      minutes = 0
    }
  }
 tags = {
    "Name" = "Business Queue"
  }
}

resource "aws_connect_queue" "first_contact_queue" {
  instance_id           = aws_connect_instance.thecloudshepherd_youtube.id
  name                  = "first_contact_queue"
  description           = "first_contact_queue"
  hours_of_operation_id = aws_connect_hours_of_operation.business_hours.id
  tags = {
    "Name" = "First contact queue",
  }

}

resource "aws_connect_routing_profile" "routing_profile" {
  instance_id               = aws_connect_instance.thecloudshepherd_youtube.id
  name                      = "routing_queue_youtube"
  default_outbound_queue_id = aws_connect_queue.first_contact_queue.id
  description               = "Youtube Routing Profile"
media_concurrencies {
    channel     = "VOICE"
    concurrency = 1
  }
queue_configs {
    channel  = "VOICE"
    delay    = 0
    priority = 1
    queue_id = aws_connect_queue.first_contact_queue.queue_id
  }
tags = {
    "Name" = "Routing Profile Demo Youtbue"
  }
}


resource "aws_connect_security_profile" "admin_security_profile" {
  instance_id = aws_connect_instance.thecloudshepherd_youtube.id
  name        = "Admin security profile"
  description = "Admin security profile"
    permissions = [
           
    "BasicAgentAccess",
    "OutboundCallAccess",
    "CreateRoutingProfile",
    "EditRoutingProfile",
    "ViewRoutingProfile",
    "CreateTransferDestination",
    "ViewQueues",
    "CreateTaskTemplate",
    "DeleteTaskTemplate",
    "EditTaskTemplate",
    "ViewTaskTemplate",
    "CreatePrompt",
    "DeletePrompt",
    "EditPrompt",
    "ViewPrompt",
    "DeleteUser",
    "EditUser"
]
        
tags = {
    "Name" = "Admin Security Profile"
  }
}
  

resource "aws_connect_user" "thecloudshepherd_youtube" {
  instance_id        = aws_connect_instance.thecloudshepherd_youtube.id
  name               = "thecloudshepherd_youtube"
  password           = "thecloudshepherd_youtube"
  routing_profile_id = aws_connect_routing_profile.routing_profile.routing_profile_id

  security_profile_ids = [
    aws_connect_security_profile.admin_security_profile.security_profile_id
  ]

  identity_info {
    first_name = "Elliott"
    last_name  = "Arnold"
  }

  phone_config {
    after_contact_work_time_limit = 0
    phone_type                    = "SOFT_PHONE"
  }
}








# resource "aws_connect_contact_flow" "test" {
#   instance_id = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
#   name        = "Test"
#   description = "Test Contact Flow Description"
#   type        = "CONTACT_FLOW"
#   content = jsonencode({
#     Version     = "2019-10-30"
#     StartAction = "12345678-1234-1234-1234-123456789012"
#     Actions = [
#       {
#         Identifier = "12345678-1234-1234-1234-123456789012"
#         Type       = "MessageParticipant"

#         Transitions = {
#           NextAction = "abcdef-abcd-abcd-abcd-abcdefghijkl"
#           Errors     = []
#           Conditions = []
#         }

#         Parameters = {
#           Text = "Thanks for calling the sample flow!"
#         }
#       },
#       {
#         Identifier  = "abcdef-abcd-abcd-abcd-abcdefghijkl"
#         Type        = "DisconnectParticipant"
#         Transitions = {}
#         Parameters  = {}
#       }
#     ]
#   })

#   tags = {
#     "Name"        = "Test Contact Flow"
#     "Application" = "Terraform"
#     "Method"      = "Create"
#   }
# }



# resource "aws_lambda_function" "test_lambda" {
#   function_name = "lambda_function_name"
#   handler       = "index.handler"
#   runtime       = "nodejs14.x"
#   role          = aws_iam_role.iam_for_lambda.arn

#   # Inline code
#   inline_code = <<EOF
#     exports.handler = async (event) => {
#       const response = {
#         statusCode: 200,
#         body: "Hello, World!"
#       };
#       return response;
#     };
#     EOF
# }

# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

#######
# Advanced 

# resource "aws_connect_lambda_function_association" "lambda_assoc" {
#   function_arn = var.lambda_function_arn
#   instance_id  = aws_connect_instance.instance.id
# }

# resource "aws_connect_contact_flow" "test" {
#   instance_id = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
#   name        = "Test"
#   description = "Test Contact Flow Description"
#   type        = "CONTACT_FLOW"
#   content = jsonencode({
#     Version     = "2019-10-30"
#     StartAction = "12345678-1234-1234-1234-123456789012"
#     Actions = [
#       {
#         Identifier = "12345678-1234-1234-1234-123456789012"
#         Type       = "MessageParticipant"

#         Transitions = {
#           NextAction = "abcdef-abcd-abcd-abcd-abcdefghijkl"
#           Errors     = []
#           Conditions = []
#         }

#         Parameters = {
#           Text = "Thanks for calling the sample flow!"
#         }
#       },
#       {
#         Identifier  = "abcdef-abcd-abcd-abcd-abcdefghijkl"
#         Type        = "DisconnectParticipant"
#         Transitions = {}
#         Parameters  = {}
#       }
#     ]
#   })

#   tags = {
#     "Name"        = "Test Contact Flow"
#     "Application" = "Terraform"
#     "Method"      = "Create"
#   }
# }

