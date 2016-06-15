provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "template_file" "chef_bootstrap" {
  template = "${file("${path.module}/templates/chef_bootstrap.tpl")}"

  vars {
    chef-server-user = "${var.chef-server-user}"
    chef-server-user-full-name = "${var.chef-server-user-full-name}"
    chef-server-user-email = "${var.chef-server-user-email}"
    chef-server-user-password = "${var.chef-server-user-password}"
    chef-server-org-name = "${var.chef-server-org-name}"
    chef-server-org-full-name = "${var.chef-server-org-full-name}"
  }
}

resource "aws_instance" "chef-server" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  tags {
    Name = "chef-server"
  }
  security_groups = ["${split(",", var.security_groups)}"]
  key_name = "${var.key_name}"

  # Sets up directories for cookbooks to create the Chef Server
  provisioner "remote-exec" {
    inline =  [
      "sudo mkdir -p /var/chef/cache",
      "sudo chown ubuntu /var/chef"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(\"${var.private_ssh_key_path}\")}"
    }
  }

  provisioner "file" {
    source = "${path.module}/cookbooks"
    destination = "~/"
    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(\"${var.private_ssh_key_path}\")}"
    }

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(\"${var.private_ssh_key_path}\")}"
    }
  }

  provisioner "remote-exec" {
    inline = <<EOF
    cat <<FILE > /tmp/dna.json
{
  "chef-server": {
    "api_fqdn": "${self.public_ip}"
  }
}
FILE
EOF

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(\"${var.private_ssh_key_path}\")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "curl -L https://www.chef.io/chef/install.sh | sudo bash",
      "sudo mkdir /etc/chef",
      "sudo chef-solo -o 'recipe[chef-server::default]' -j /tmp/dna.json",
      "echo '${template_file.chef_bootstrap.rendered}' > /tmp/bootstrap-chef-server.sh",
      "chmod +x /tmp/bootstrap-chef-server.sh",
      "sudo sh /tmp/bootstrap-chef-server.sh",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file(\"${var.private_ssh_key_path}\")}"
    }
  }
}
