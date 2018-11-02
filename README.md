# AWS EC2 Instance Base Terrafrom Module

Terraform module which is used as a base to create EC2 instance(s) on AWS
The module performs the following functionality:

- Looks-up AMI ID
- Creates default security group
- Creates instance IAM Role with policy ARN attachments
- Generates cloud-init userdata
- Default tags
- Launches instance

## Usage

```yaml
#templates/cloud_config.tpl

repo_update: true
repo_upgrade: all

packages:
  - dnsmasq

write_files:
  - path: /etc/dnsmasq.d/forward.conf
    encoding:
    content: |
      server=10.54.5.2
runcmd:
  - systemctl daemon-reload
  - systemctl enable dnsmasq
  - systemctl restart dnsmasq
```

```hcl
data "template_file" "cloud_config" {
  template = "${file("${path.module}/templates/cloud_config.tpl")}"
}
```

```yaml
#templates/cloud_config_users.tpl
users:
  - default
  - name: ansible
    gecos: Ansible User
    groups: wheel
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ssh-rsa AAAAB.................
```

```hcl
data "template_file" "cloud_config_users" {
  template = "${file("${path.module}/templates/cloud_config_users.tpl")}"
}
```

```hcl
module "instance" {
  name   = "dev01"
  source  = "sailthru/ec2-instance-base/aws"
  version = "0.0.1"
  default_keypair        = "default"
  vpc_id                 = "vpc-1a2b3d4d"
  subnet_id              = "subnet-eddcdzz4"
  private_ip             = "10.54.5.10"
  vpc_security_group_ids = ["sg-12345678"]
  cloud_config           = "${data.template_file.cloud_config.rendered}"
  cloud_config_users     = "${data.template_file.cloud_config_users.rendered}"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami_filter_name | AMI Filter name tag value | list | `<list>` | no |
| ami_filter_owner-alias | AMI Filter owner-alias tag value | list | `<list>` | no |
| ami_filter_virtualization_type | AMI Filter virtualization-type tag value | list | `<list>` | no |
| ami_id | AMI ID, setting this will disable the ami filter | string | `` | no |
| associate_public_ip_address | If true, the EC2 instance will have associated public IP address | string | `false` | no |
| cloud_config | Cloud config body: this can contain any valid cloud config configuration syntax | string | `` | no |
| cloud_config_users | Cloud config groups and users: this can contain any valid cloud config configuration syntax | string | `` | no |
| cpu_credits | The credit option for CPU usage (unlimited or standard) | string | `standard` | no |
| default_keypair | The key name to use for the instance | string | `` | no |
| default_policies | List of default policy ARN's. Pass an empty list to disable | list | `<list>` | no |
| disable_api_termination | If true, enables EC2 Instance Termination Protection | string | `false` | no |
| ebs_block_device | Additional EBS block devices to attach to the instance | list | `<list>` | no |
| ebs_optimized | If true, the launched EC2 instance will be EBS-optimized | string | `false` | no |
| egress_cidr_blocks | List of IPv4 CIDR ranges to use on all egress rules | list | `<list>` | no |
| egress_rules | List of egress rules to create by name | list | `<list>` | no |
| egress_with_cidr_blocks | List of egress rules to create where 'cidr_blocks' is used | list | `<list>` | no |
| egress_with_self | List of egress rules to create where 'self' is defined | list | `<list>` | no |
| egress_with_source_security_group_id | List of egress rules to create where 'source_security_group_id' is used | list | `<list>` | no |
| ephemeral_block_device | Customize Ephemeral (also known as Instance Store) volumes on the instance | list | `<list>` | no |
| iam_policies | List of policy ARN's to attatch to instance role | list | `<list>` | no |
| ingress_cidr_blocks | List of IPv4 CIDR ranges to use on all ingress rules | list | `<list>` | no |
| ingress_rules | List of ingress rules to create by name | list | `<list>` | no |
| ingress_with_cidr_blocks | List of ingress rules to create where 'cidr_blocks' is used | list | `<list>` | no |
| ingress_with_self | List of ingress rules to create where 'self' is defined | list | `<list>` | no |
| ingress_with_source_security_group_id | List of ingress rules to create where 'self' is defined | list | `<list>` | no |
| instance_initiated_shutdown_behavior | Shutdown behavior for the instance | string | `` | no |
| instance_type | The type of instance to start | string | `t3.micro` | no |
| monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | string | `false` | no |
| name | Resource name. This will be used as a tag prefix | string | - | yes |
| placement_group | The Placement Group to start the instance in | string | `` | no |
| private_ip | Private Ip to assign instances. Must match aws_private_subnet_id network | string | `` | no |
| subnet_id | subnet to launch instnace in | string | `` | no |
| root_block_device | Customize details about the root block device of the instance. See Block Devices below for details | list | `<list>` | no |
| source_dest_check | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | string | `true` | no |
| tags | Additional instance tags | map | `<map>` | no |
| tenancy | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host. | string | `default` | no |
| volume_tags | A mapping of tags to assign to the devices created by the instance at launch time | map | `<map>` | no |
| vpc_id | AWS VPC ID | string | - | yes |
| vpc_security_group_ids | List of VPC security group ID's to attach to the instance | list | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability_zone | List of availability zones of instances |
| credit_specification | List of credit specification of instances |
| id | List of IDs of instances |
| key_name | List of key names of instances |
| network_interface_id | List of IDs of the network interface of instances |
| primary_network_interface_id | List of IDs of the primary network interface of instances |
| private_dns | List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| private_ip | List of private IP addresses assigned to the instances |
| public_dns | List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC |
| public_ip | List of public IP addresses assigned to the instances, if applicable |
| security_groups | List of associated security groups of instances |
| subnet_id | List of IDs of VPC subnets of instances |
| tags | List of tags of instances |
| vpc_security_group_ids | List of associated security groups of instances, if running in non-default VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Sailthru](https://github.com/sailthru).

## License

Apache 2 Licensed. See LICENSE for full details.
