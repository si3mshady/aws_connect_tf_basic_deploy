#Basic setup for AWS Connect
terraform {
    required_providers {
       aws = {
          source  = "hashicorp/aws"
         
     }
   }
 }

provider "aws" {
    region = "us-east-1"
}

#Before deployment comment out aws_connect_routing_profile and aws_connect_user if you using Terraform v1.5.7

#To find the basic queue id of each instance after deployed needed to configure routing profile 
#comment out 
#  aws connect list-instances (get instance id from cli output)
# then run
# aws connect list-queues --instance-id a2bfeb88-7bd7-484e-9684-26d420ab3b4c
# get the ID of the basic queue and place appropriately for inside routing profile 
# update queue id in 2 places for queue: queue-id and defaut queue


resource "aws_connect_instance" "thecloudshepherd_youtube" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  instance_alias           = "thecloudshepherdlinkedin"
  outbound_calls_enabled   = true
}

# reached limit service quota will have another demo where I set this up =)

# resource "aws_connect_phone_number" "thecloudshepherd" {
#   target_arn   = aws_connect_instance.thecloudshepherd_youtube.arn
#   depends_on = [ aws_connect_hours_of_operation.business_hours ]
#   country_code = "US"
#   type         = "DID"
#   tags = {
#     "number" = "US"
#   }
# }

resource "aws_connect_hours_of_operation" "business_hours" {
  instance_id = aws_connect_instance.thecloudshepherd_youtube.id
  name        = "Business Hours"
  description = "Open For Business"
  time_zone   = "EST"
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

#use aws cli to get the default queue id - 
# aws connect list-instances
# aws connect list-queues --instance-id 14dcff5c-ef79-4c25-8f59-1039d56141da

# # routing profile 

resource "aws_connect_routing_profile" "routing_profile" {
  instance_id               = aws_connect_instance.thecloudshepherd_youtube.id
  name                      = "routing_queue_youtube"
  default_outbound_queue_id = "6304de78-99b0-4af6-854f-7998c8216969"
  description               = "Youtube Routing Profile"
media_concurrencies {
    channel     = "VOICE"
    concurrency = 1
  }
queue_configs {
    channel  = "VOICE"
    delay    = 0
    priority = 1
    queue_id = "6304de78-99b0-4af6-854f-7998c8216969"
  }
tags = {
    "Name" = "Routing Profile Demo Youtbue"
  }
}



resource "aws_connect_user" "thecloudshepherd_youtube" {
  instance_id        = aws_connect_instance.thecloudshepherd_youtube.id
  name               = "Thecl0udshepherd_youtube_3"
  password           = "Thecl0udshepherd_youtube_3"
  routing_profile_id = aws_connect_routing_profile.routing_profile.routing_profile_id

  security_profile_ids = [
    aws_connect_security_profile.admin_security_profile.security_profile_id
  ]

  identity_info {
    first_name = "Elliot"
    last_name  = "AD"
  }

  phone_config {
    after_contact_work_time_limit = 0
    phone_type                    = "SOFT_PHONE"
  }
}


resource "aws_connect_security_profile" "admin_security_profile" {
  instance_id = aws_connect_instance.thecloudshepherd_youtube.id
  name        = "Admin security profile"
  description = "Admin security profile"
    permissions = [
          "Users.Create",
    "BasicAgentAccess",
    "OutboundCallAccess",
   
]
        
tags = {
    "Name" = "Admin Security Profile"
  }
}
  

resource "aws_connect_contact_flow" "test" {
  instance_id = aws_connect_instance.thecloudshepherd_youtube.id
  name        = "Test"
  description = "Test Contact Flow Description"
  type        = "CONTACT_FLOW"
  content = jsonencode({
    Version     = "2019-10-30"
    StartAction = "12345678-1234-1234-1234-123456789012"
    Actions = [
      {
        Identifier = "12345678-1234-1234-1234-123456789012"
        Type       = "MessageParticipant"

        Transitions = {
          NextAction = "abcdef-abcd-abcd-abcd-abcdefghijkl"
          Errors     = []
          Conditions = []
        }

        Parameters = {
          Text = "Thanks for calling the sample flow!"
        }
      },
      {
        Identifier  = "abcdef-abcd-abcd-abcd-abcdefghijkl"
        Type        = "DisconnectParticipant"
        Transitions = {}
        Parameters  = {}
      }
    ]
  })

  tags = {
    "Name"        = "Test Contact Flow"
    "Application" = "Terraform"
    "Method"      = "Create"
  }
}


