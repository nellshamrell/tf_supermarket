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

module "supermarket-bucket" {
  source = "./supermarket-bucket"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
  aws_user_arn = "${var.aws_user_arn}"
  aws_iam_username = "${var.aws_iam_username}"
  bucket_name = "${var.bucket_name}"
  bucket_acl = "${var.bucket_acl}"
}

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
}

resource "null_resource" "fetch_chef_server_cert" {
  depends_on = ["template_file.knife_rb"]
  # Fetch Chef Server Certificate
  provisioner "local-exec" {
    # changing to the parent directory so the trusted cert goes into ../.chef/trusted_certs
    command = "knife ssl fetch"
  }
}

# Add Supermarket cookbooks to Chef Server
resource "null_resource" "upload-supermarket-cookbooks" {
  depends_on = ["template_file.knife_rb", "null_resource.fetch_chef_server_cert"]
  provisioner "local-exec" {
    command = "knife cookbook upload --all --cookbook-path supermarket-server/cookbooks"
  }
}

# Create Supermarket oc-id app on Chef Server
resource "null_resource" "supermarket_oc_id_app" {
  depends_on = ["template_file.knife_rb"]
  # Temporarily change ownership of /etc/opscode/chef-server.rb to ubuntu so we can edit it through ssh
  provisioner "local-exec" {
    command = "ssh -i ${var.private_ssh_key_path} ubuntu@${module.chef-server.public_ip} sudo chown ubuntu /etc/opscode/chef-server.rb "
  }

  provisioner "local-exec" {
    command = <<EOT
      ssh -i ${var.private_ssh_key_path} ubuntu@${module.chef-server.public_ip} 'echo \oc_id[\"applications\"] = { \"supermarket\" =\> { \"redirect_uri\" =\> \"https://${module.supermarket-server.public_ip}/auth/chef_oauth2/callback\" } } >> /etc/opscode/chef-server.rb'
    EOT
  }

  provisioner "local-exec" {
    command = "ssh -i ${var.private_ssh_key_path} ubuntu@${module.chef-server.public_ip} sudo chown root /etc/opscode/chef-server.rb "
  }

  provisioner "local-exec" {
    command = "ssh -i ${var.private_ssh_key_path} ubuntu@${module.chef-server.public_ip} sudo chef-server-ctl reconfigure"
  }
}

# Get Supermarket oc-id app info

resource "null_resource" "get-supermarket-oc-id-info" {
  depends_on = ["null_resource.supermarket_oc_id_app"]
  # Extract uid from supermarket oc-id config
  provisioner "local-exec" {
    command = "ssh -oStrictHostKeyChecking=no -i ${var.private_ssh_key_path} ubuntu@${module.chef-server.public_ip} \"sudo cat /etc/opscode/oc-id-applications/supermarket.json | grep -Ei '\"uid\".*?,'\" > uid.txt"
  }

  # Extract secret from supermarket oc-id config
  provisioner "local-exec" {
    command = "ssh -oStrictHostKeyChecking=no -i ${var.private_ssh_key_path} ubuntu@${module.chef-server.public_ip} \"sudo cat /etc/opscode/oc-id-applications/supermarket.json | grep -Ei '\"secret\".*?,'\" > secret.txt"
  }
}

# Create Supermarket data bag
resource "null_resource" "supermarket-databag-setup" {
  depends_on = ["null_resource.get-supermarket-oc-id-info"]

  # Make a data bags directory
  provisioner "local-exec" {
    command = "mkdir -p databags/apps"
  }

  # Make json file for supermarket data bag item
  # Using a heredoc, rather than a template
  # Because I could not pass the values of oc-id.txt and secret.txt
  # to the template because they are dynamically created when the terraform
  # config runs
  provisioner "local-exec" {
    command = <<EOF
    cat <<FILE > databags/apps/supermarket.json
{
  "id": "supermarket",
  "fqdn": "${module.supermarket-server.public_ip}",
  "chef_server_url": "https://${module.chef-server.public_ip}",
  ${file("uid.txt")}
  ${file("secret.txt")}
  "features": "tools,fieri,github,announcement",
  "s3_bucket": "${var.bucket_name}",
  "s3_access_key_id": "${var.access_key}",
  "s3_secret_access_key": "${var.secret_key}",
  "fieri_results_endpoint": "https://${module.supermarket-server.public_dns}/api/v1/cookbook-versions/evaluation",
  "fieri_key": "${var.fieri_key}"
}
FILE
EOF
  }
}

resource "null_resource" "supermarket-databag-upload" {
  depends_on = ["null_resource.supermarket-databag-setup","null_resource.fetch_chef_server_cert"]
  # Create the apps data bag on the Chef server
  provisioner "local-exec" {
    command = "knife data bag create apps"
  }

  # Create supermarket data bag item on the Chef server
  provisioner "local-exec" {
    command = "knife data bag from file apps databags/apps/supermarket.json"
  }
}

# Create Supermarket node
resource "null_resource" "supermarket-node-setup" {
  depends_on = ["null_resource.supermarket-databag-upload"]
  provisioner "local-exec" {
    command = "knife bootstrap ${module.supermarket-server.public_ip} -i ${var.private_ssh_key_path} -N supermarket-node -x ubuntu --sudo"
  }
}

# Configure Supermarket node
resource "null_resource" "configure-supermarket-node-run-list" {
  depends_on = ["null_resource.supermarket-node-setup"]
  provisioner "local-exec" {
    command = "knife node run_list add supermarket-node 'recipe[supermarket-wrapper::default]'"
  }
}

resource "null_resource" "supermarket-node-client" {
  depends_on = ["null_resource.configure-supermarket-node-run-list"]
  provisioner "local-exec" {
    command = "ssh -i ${var.private_ssh_key_path} ubuntu@${module.supermarket-server.public_ip} 'sudo chef-client'"
  }
}

# Fetch Supermarket SSL Cert to workstation
resource "null_resource" "fetch-supermarket-ssl-cert" {
  depends_on = ["null_resource.supermarket-node-client"]
  provisioner "local-exec" {
    command = "knife ssl fetch https://${module.supermarket-server.public_ip}"
  }
}
