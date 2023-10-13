provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}


resource "aws_connect_instance" "test" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  instance_alias           = "friendly-name-connect"
  outbound_calls_enabled   = true
}

resource "aws_connect_routing_profile" "example" {
  instance_id               = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
  name                      = "example"
  default_outbound_queue_id = "12345678-1234-1234-1234-123456789012"
  description               = "example description"

  media_concurrencies {
    channel     = "VOICE"
    concurrency = 1
  }

  queue_configs {
    channel  = "VOICE"
    delay    = 2
    priority = 1
    queue_id = "12345678-1234-1234-1234-123456789012"
  }

  tags = {
    "Name" = "Example Routing Profile",
  }
}
resource "aws_connect_queue" "test" {
  instance_id           = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
  name                  = "Example Name"
  description           = "Example Description"
  hours_of_operation_id = "12345678-1234-1234-1234-123456789012"

  tags = {
    "Name" = "Example Queue",
  }
}

resource "aws_connect_contact_flow" "test" {
  instance_id = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
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

resource "aws_connect_user" "example" {
  instance_id        = aws_connect_instance.example.id
  name               = "example"
  password           = "Password123"
  routing_profile_id = aws_connect_routing_profile.example.routing_profile_id

  security_profile_ids = [
    aws_connect_security_profile.example.security_profile_id
  ]

  identity_info {
    first_name = "example"
    last_name  = "example2"
  }

  phone_config {
    after_contact_work_time_limit = 0
    phone_type                    = "SOFT_PHONE"
  }
}

resource "aws_connect_security_profile" "example" {
  instance_id = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
  name        = "example"
  description = "example description"

  permissions = [
    "BasicAgentAccess",
    "OutboundCallAccess",
  ]

  tags = {
    "Name" = "Example Security Profile"
  }
}

resource "aws_connect_phone_number" "example" {
  target_arn   = aws_connect_instance.example.arn
  country_code = "US"
  type         = "DID"

  tags = {
    "hello" = "world"
  }
}


resource "aws_connect_contact_flow_module" "example" {
  instance_id = "aaaaaaaa-bbbb-cccc-dddd-111111111111"
  name        = "Example"
  description = "Example Contact Flow Module Description"

  content = jsonencode({
    Version     = "2019-10-30"
    StartAction = "12345678-1234-1234-1234-123456789012"
    Actions = [
      {
        Identifier = "12345678-1234-1234-1234-123456789012"

        Parameters = {
          Text = "Hello contact flow module"
        }

        Transitions = {
          NextAction = "abcdef-abcd-abcd-abcd-abcdefghijkl"
          Errors     = []
          Conditions = []
        }

        Type = "MessageParticipant"
      },
      {
        Identifier  = "abcdef-abcd-abcd-abcd-abcdefghijkl"
        Type        = "DisconnectParticipant"
        Parameters  = {}
        Transitions = {}
      }
    ]
    Settings = {
      InputParameters  = []
      OutputParameters = []
      Transitions = [
        {
          DisplayName   = "Success"
          ReferenceName = "Success"
          Description   = ""
        },
        {
          DisplayName   = "Error"
          ReferenceName = "Error"
          Description   = ""
        }
      ]
    }
  })

  tags = {
    "Name"        = "Example Contact Flow Module",
    "Application" = "Terraform",
    "Method"      = "Create"
  }
}
