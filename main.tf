# Find this VPC CIDR Block
data "aws_vpc" "this_vpc" {
  id = "${var.vpc_id}"
}

# Find Amazon Linux AMI
data "aws_ami" "this_ami" {
  most_recent = true # Find and return the most recent match. \m/
  owners = ["${var.ami_filter_owner-alias}"]

  filter {
    name = "name"
    values = "${var.ami_filter_name}"
  }
  filter {
    name = "virtualization-type"
    values = "${var.ami_filter_virtualization_type}"
  }
}

# IAM roles for the instances
data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this_instance_role" {
  name_prefix        = "${var.name}-instance-role-"
  path               = "/system/"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

resource "aws_iam_instance_profile" "this_instance_profile" {
  name_prefix = "${var.name}-instance-profile-"
  role        = "${aws_iam_role.this_instance_role.name}"
}

resource "aws_iam_role_policy_attachment" "attach_iam_policies" {
  count      = "${length(local.iam_policies)}"
  role       = "${aws_iam_role.this_instance_role.name}"
  policy_arn = "${local.iam_policies[count.index]}"
}

# Default security group
module "instance_default_sg" {
  source = "terraform-aws-modules/security-group/aws"
  name                     = "${var.name}-default"
  description              = "Default instance security group"
  vpc_id                   = "${var.vpc_id}"
  ingress_cidr_blocks      = "${var.ingress_cidr_blocks}"
  ingress_rules            = "${var.ingress_rules}"
  ingress_with_self        = "${var.ingress_with_self}"
  egress_cidr_blocks       = "${var.egress_cidr_blocks}"
  egress_rules             = "${var.egress_rules}"
  ingress_with_cidr_blocks = "${var.ingress_with_cidr_blocks}"
  egress_with_cidr_blocks  = "${var.egress_with_cidr_blocks}"
  tags                     = "${ merge(local.default_tags, var.tags) }"
}

# Generate the cloud init
data "template_cloudinit_config" "cloud-init" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content     = "${var.cloud_config_users}"
  }

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content     = "${var.cloud_config}"
  }
}

# Launch instances
resource "aws_instance" "this" {
  ami                    = "${ var.ami_id == "" ? data.aws_ami.this_ami.id : var.ami_id}"
  instance_type          = "${var.instance_type}"
  user_data              = "${data.template_cloudinit_config.cloud-init.rendered}"
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.default_keypair}"
  vpc_security_group_ids = ["${
    sort(
      distinct(
        concat(
          var.vpc_security_group_ids,
          list(module.instance_default_sg.this_security_group_id)
        )
      )
    )
  }"]
  iam_instance_profile   = "${aws_iam_instance_profile.this_instance_profile.id}"
  tags                   = "${ merge(local.default_tags, var.tags) }"
  associate_public_ip_address          = "${var.associate_public_ip_address}"
  private_ip                           = "${var.private_ip}"
  source_dest_check                    = "${var.source_dest_check}"
  disable_api_termination              = "${var.disable_api_termination}"
  instance_initiated_shutdown_behavior = "${var.instance_initiated_shutdown_behavior}"
  placement_group                      = "${var.placement_group}"
  tenancy                              = "${var.tenancy}"
  ebs_optimized                        = "${var.ebs_optimized}"
  monitoring                           = "${var.monitoring}"
  volume_tags                          = "${var.volume_tags}"
  root_block_device                    = "${var.root_block_device}"
  ebs_block_device                     = "${var.ebs_block_device}"
  ephemeral_block_device               = "${var.ephemeral_block_device}"
  
  credit_specification {
    cpu_credits = "${var.cpu_credits}"
  }
  
  lifecycle {
     ignore_changes = ["private_ip", "root_block_device", "ebs_block_device"]
  }
}
