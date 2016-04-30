provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

module "security-group" {
  source = "./security-group"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

module "chef-server" {
  source = "./chef-server"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"

  # Must be assigned to the default security group to be able to connect to other instances (i.e. the RDS DB) on the same VPC
  security_groups = "${module.security-group.security-group-name},default"

  key_name = "${var.key_name}"
  private_ssh_key_path = "${var.private_ssh_key_path}"
  chef-server-user = "${var.chef-server-user}"
  chef-server-user-full-name = "${var.chef-server-user-full-name}"
  chef-server-user-email = "${var.chef-server-user-email}"
  chef-server-user-password = "${var.chef-server-user-password}"
  chef-server-org-name = "${var.chef-server-org-name}"
  chef-server-org-full-name = "${var.chef-server-org-full-name}"
}

module "supermarket-server" {
  source = "./supermarket-server"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"

  # Must be assigned to the default security group to be able to connect to other instances (i.e. the RDS DB) on the same VPC
  security_groups = "${module.security-group.security-group-name},default"

  key_name = "${var.key_name}"
}

# Spin up supermarket db

# Spin up supermarket cache

# Spin up supermarket bucket

# Spin up Fieri server

# Configure workstation

resource "template_file" "knife_rb" {
  template = "${file("${path.module}/templates/knife_rb.tpl")}"
  vars {
    chef-server-user = "${var.chef-server-user}"
    organization = "${var.chef-server-org-name}"
    chef-server-fqdn = "${module.chef-server.public_ip}"
    chef-server-organization = "${var.chef-server-org-name}"
    supermarket-server-fqdn = "${module.supermarket-server.public_ip}"
  }
  # Make .chef/knife.rb file
  provisioner "local-exec" {
    command = "mkdir -p .chef && echo '${template_file.knife_rb.rendered}' > .chef/knife.rb"
  }

  # Download chef validation pem
  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no -i ${var.private_ssh_key_path} ubuntu@${module.chef-server.public_ip}:${var.chef-server-user}.pem .chef"
  }

  # Fetch Chef Server Certificate
  provisioner "local-exec" {
    # changing to the parent directory so the trusted cert goes into ../.chef/trusted_certs
    command = "knife ssl fetch"
  }
}

# Add Supermarket cookbooks to Chef Server
resource "null_resource" "upload-supermarket-cookbooks" {
  depends_on = ["template_file.knife_rb"]
  provisioner "local-exec" {
    command = "knife cookbook upload --all --cookbook-path supermarket-server/cookbooks"
  }
}
# Create Supermarket oc-id app on Chef Server

# Create Supermarket data bag

# Create Supermarket node

# Configure Supermarket node

# Create Fieri data bag

# Configure Fieri node

# Transfer Supermarket certificate to Fieri
