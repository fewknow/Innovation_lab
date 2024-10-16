provider "aws" {
  region = "us-west-2"
}

module "multi_team_setup" {
  source                   = "../../modules/multi_team_module"  # Adjust based on your structure
  region                   = "us-west-2"
  vpc_cidr                 = "10.0.0.0/16"
  availability_zones       = ["us-west-2a", "us-west-2b"]
  map_public_ip_on_launch  = false
  environment              = "dev"

  teams = {
    "AppTeamA" = {
      subnet_index = 0
      emails       = ["userA1@example.com", "userA2@example.com"]
    }
    "AppTeamB" = {
      subnet_index = 1
      emails       = ["userB1@example.com", "userB2@example.com"]
    }
  }
}
