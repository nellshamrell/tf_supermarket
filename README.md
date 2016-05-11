# This is for Test use ONLY!  I do not recommend using it in production!

# Chef Supermarket Terraform Cluster - Proof of Concept

This is a terraform configuration to spin up a Chef Server, Supermarket Server, and Fieri Server and configure them to work together 

This ONLY works in AWS

## Requirements
You must have Git, ChefDK, and Terraform installed on your local workstation.

You must have an AWS account including an AWS Access Key, AWS Secret Key, and AWS IAM user

To upload cookbooks, you must also have the [knife supermarket plugin](https://github.com/chef/knife-supermarket) installed.

## What this does

This Terraform config will:

1. Spin up a [Supermarket](https://github.com/chef/supermarket) server in AWS
2. Spin up a [Chef Server](https://github.com/chef/chef-server) in AWS, then register the Supermarket with the Chef Server so Supermarket can use oc_id for auth
3. Make some changes to your workstation - including setting up a .chef/knife.rb file with the new Chef Server and Supermarket information
4. Upload a databag with information for Supermarket to use when it is configured 
7. Spin up a new S3 bucket for artifact storage and connect it to your Supermarket
8. Spin up a [Fieri](https://github.com/chef/fieri) server in AWS and connect it to your Supermarket

NOTE: In the future, this may also spin up an Elasticache instance and RDS instance and connect them to Supermarket, but it does not do so at this time.

This is a high level overview, please see the actual config files for more detail about what is executed when.

## Usage

First clone this repo to your local workstation

```bash
  $ git clone git@github.com:nellshamrell/tf_supermarket.git
```

Then change into that directory

```bash
  $ cd tf_supermarket
```

Now copy the terraform.tfvars.example to a new file called terraform.tfvars

```bash
  $ cp terraform.tfvars.example terraform.tfvars
```

Now open up then new file with your preferred text editor and fill in the appropriate values (i.e. AWS Access Key, AWS Key Pair, etc.)

Next, get the modules included in this repo:

```bash
  $ terraform get
```

Check that your Terraform config looks good

```bash
  $ terraform plan
```

Then spin up your cluster!

```bash
  $ terraform apply
```

And you have a ready to use Supermarket, Chef Server, Fieri server, and S3 bucket all configured to work together 

NOTE: Before you can upload a cookbook to your Supermarket, you must log into your Supermarket through a browser to complete the final step in linking your Supermarket account with your Chef Server account.

To test uploading a cookbook to Supermarket, run this command from the same directory as tf_supermarket

```bash
  $ knife supermarket share supermarket-wrapper --cookbook-path supermarket-server/cookbooks
```
When you're done, use this command to destroy your cluster!

```bash
  $ terraform destroy
```
