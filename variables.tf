variable "name" {
  description = "Resource name. This will be used as a tag prefix"
}

variable "ami_filter_name" {
  description = "AMI Filter name tag value"
  default = ["amzn2-ami-*-x86_64-gp2"]
}

variable "ami_filter_virtualization_type" {
  description = "AMI Filter virtualization-type tag value"
  default = ["hvm"]
}

variable "ami_filter_owner-alias" {
  description = "AMI Filter owner-alias tag value"
  default = ["amazon"]
}

variable "iam_policies" {
  description = "List of policy ARN's to attatch to instance role"
  default = []
}

variable  "default_policies" {
  description = "List of default policy ARN's. Pass an empty list to disable"
  default = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"]
}

# Instance 
variable "vpc_id" {
  description = "AWS VPC ID"
  type = "string"
}

variable "ami_id" {
  description = "AMI ID, setting this will disable the ami filter"
  default = ""
}

variable "subnet_id" {
  description = "Subnets to launch instnaces in"
  default = ""
}

variable "tags" {
  description = "Additional instance tags"
  default = {}
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  default     = ""
}

variable "instance_type" {
  description = "The type of instance to start"
  default     = "t3.micro"
}

variable "default_keypair" {
  description = "The key name to use for the instance"
  default     = ""
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable "private_ip" {
  description = "rivate IP to assign instances. Must match aws_private_subnet_id network"
  default     = ""
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  default     = {}
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  default     = []
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  default     = []
}

variable "cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)"
  default     = "standard"
}

# Security groups
variable "vpc_security_group_ids" {
  description = "List of VPC security group ID's to attach to the instance"
  default = []
}

variable "ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules"
  default = []
}
variable "ingress_rules" {
  description = "List of ingress rules to create by name"
  default = []
}

variable "ingress_with_cidr_blocks" {
  description = "List of ingress rules to create where 'cidr_blocks' is used"
  default = []
}

variable "ingress_with_self" {
  default = []
  description = "List of ingress rules to create where 'self' is defined"
}

variable "ingress_with_source_security_group_id" {
  description = "List of ingress rules to create where 'self' is defined"
  default = []
}

variable "egress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all egress rules"
  default = []
}

variable "egress_rules" {
  description = "List of egress rules to create by name"
  default = []
}

variable "egress_with_cidr_blocks" {
  description = "List of egress rules to create where 'cidr_blocks' is used"
  default = []
}

variable "egress_with_self" {
  description = "List of egress rules to create where 'self' is defined"
  default = []
}

variable "egress_with_source_security_group_id" {
  description = "List of egress rules to create where 'source_security_group_id' is used"
  default = []
}

# Cloud init
variable "cloud_config_users" {
  description = "Cloud config groups and users: this can contain any valid cloud config configuration syntax"
  default = ""
}

variable "cloud_config" {
  description = "Cloud config body: this can contain any valid cloud config configuration syntax"
  default = ""
}

# Defaults
locals {
  default_tags = { 
    "Name"      = "${var.name}"
    "Terraform" = true
  }
  
  iam_policies = "${
    sort(distinct(concat(var.iam_policies,var.default_policies)))
  }"

  
}
