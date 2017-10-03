--
layout:     post
title:      "Terraform remote state part 2"
subtitle:   "Terraform remote state part 2."
date:       2017-09-19 16:30:00
author:     "Mattias Gees"
header-img: "img/standard.jpg "
---

# Terraform remote state part 2

Two years ago I [wrote](http://blog.mattiasgees.be/2015/07/29/terraform-remote-state/) about using Terraform remote state. Since then a lot has changed in Terraform and it was about time to write an update on Terraform remote state and its current usage.

## Introduction

At Skyscrapers we use S3 to save all our remote states. We even [setup](https://github.com/skyscrapers/terraform-state/) our S3 bucket where we save our remote state with Terraform.

Our S3 buckets are configured with versioning enabled. (that way we can always roll-back if needed). Our S3 bucket has a policy to only allow encrypted uploads of the remote state. Hence  we are ensured that our remote state is securely stored in our S3 buckets. A remote state can contain passwords and other secrets.

Since version [0.9.0](https://github.com/hashicorp/terraform/blob/master/CHANGELOG.md#090-march-15-2017) Terraform has introduced state locking, which we immediately started using. This feature ensures that only one person or process can make changes to our infrastructure. As we are an AWS partner, we use Amazon DynamoDB to lock our state file.

## Configure remote state

Over the last two years  how you configure your remote state has changed quite a bit. Where earlier you had to configure your remote state on every location manually with `terraform remote config`, you can now do the config inside your Terraform project. One less task to remember when you start working on a Terraform project!

Now you configure your remote state as a code block inside your Terraform project.
```
terraform {
 required_version = ">= 0.10.1"

 backend "s3" {
   bucket         = "terraform-state-example-default"
   key            = "static/main"
   region         = "eu-west-1"
   dynamodb_table = "terraform-state-lock-example-default"
   encrypt        = true
 }
}
```

This config will indicate to Terraform that it has to save your remote state to S3 in the `terraform-state-example-default` with a key called `static/main`. You want to have your remote state file encrypted and you are using a state lock table called `terraform-state-lock-example-default`.

After adding the above to your project, you need to run the newly introduced `terraform init` command. This command will fetch all  the modules that you  are using in Terraform project, your remote state as well as your terraform providers since 0.10.0.

After doing this, your remote state is set up and you can start using it by running your normal Terraform commands. Your state will automatically be saved to S3.

## Using remote state in other Terraform projects

The way you use remote state outputs in other Terraform projects has changed as well since [0.7.0](https://github.com/hashicorp/terraform/blob/master/CHANGELOG.md#070-august-2-2016).. Outputs are defined the same, but how you get those outputs in other Terraform projects has changed. 

First you have to define some outputs in your main Terraform projects
```
output "vpc_id" {
 value = "${aws_vpc.main.id}"
}

output "proxy_subnets" {
 value = "${aws_subnet.proxy_subnets.*}" !!! CHANGE THIS
}
```

After a terraform apply/refresh you will see the following.

```
Outputs:
 proxy_subnets      = subnet-1232ae34,subnet-abc41234,subnet-abc1e399
 vpc_id             = vpc-1232ae34
```

Now go to the project where you want to use those outputs. We don't need to declare a resource but rather a datasource. You can take a datasource quite literally:  you can only get data from it, but it will not make changes to anything.
After you declare your datasource, you can use the outputs as input for modules and other elements. You can call the outputs the following way `${data.terraform_remote_state.<data_name>.<output_name>}`. An example is:

```
data "terraform_remote_state" "static" {
 backend     = "s3"

 config {
   bucket = "terraform-state-example-default"
   key    = "static/main"
   region = "eu-west-1"
 }
}

module "app" {
 source  = "modules/blue-green"
 name    = "app"
 vpc_id  = "${data.terraform_remote_state.static.vpc_id}"
 subnets = "${data.terraform_remote_state.static.app_subnets}"
}
```

## Terraform workspaces

Since terraform [0.9.0](https://github.com/hashicorp/terraform/blob/master/CHANGELOG.md#090-march-15-2017) we have terraform environments, now called terraform workspaces. These workspaces  make it possible to easily deploy the same infrastructure to multiple environments (eg. production and staging). You don't need to hack around with reconfiguration of remote config or maintaining multiple code paths. With just one command you can switch between workspaces.

I will not go into detailsabout Terraform workspaces, but I suggest you read the [official documentation](https://www.terraform.io/docs/state/workspaces.html). A more detailed blogpost about Terraform Workspaces will follow.

Terraform workspaces can be used without any problem with remote states. Not all remote states support this feature, but S3 and Consul do.

There is only one mandatory change you have to make when you are using remote state and Terraform workspace, namelyin the declaration of your dataresource in the Terraform project where you want to use the output of a remote state. You will need to add key called `workspace`. This needs to point to the name of your workspace of your remote state. If your workspaces are the same in the Terraform project where you defined the output, you can use the `${terraform.workspace}` variable to map it 1:1. A full example below:

```
data "terraform_remote_state" "static" {
 backend     = "s3"
 environment = "${terraform.workspace}"

 config {
   bucket = "terraform-state-example-default"
   key    = "static/main"
   region = "eu-west-1"
 }
}
```


