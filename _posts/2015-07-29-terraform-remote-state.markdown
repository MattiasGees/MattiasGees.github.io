---
layout:     post
title:      "Terraform remote state"
subtitle:   "Setting up Terraform remote state."
date:       2015-07-29 16:30:00
author:     "Mattias Gees"
header-img: "img/standard.jpg "
---

# Introduction

For an Amazon AWS project at [work](http://skyscrapers.eu), we are setting up a complete Amazon AWS infrastructure with Terraform. The first step was to setup a VPC, ELBs, RDS and basic EC2 instances.

I started looking into the remote state capabilities of Terraform together with S3 storage, because it lets us work together without the need to check-in the Terraform state files to our source control, while still saving it at a central place.

Putting your Terraform state file on Aamazon S3 has an other advantage: you can use Terraform outputs into other projects. This solution came in handy when we wanted to setup [blue/green deployment](http://martinfowler.com/bliki/BlueGreenDeployment.html) with AWS autoscaling.

By dividing the static parts (ELB, RDS, VPC, ...) from the dynamic parts (Autoscaling groups), we created an extra security layer. When we automate the blue/green deployment through job servers (Jenkins, TravisCI, CircleCI), we have an extra security layer, where we can't destroy the static parts by accident when deploying a new version of the software.

# Configure remote state

First make sure you have AWS API credentials defined in your AWS CLI tool or as environment variable. You need to do this as Terraform remote state does not use your Terraform variables but the system AWS credentials. If you have different AWS accounts where you deploy your infrastructure, you can still put every state file in the same S3 bucket.

```bash
# Configure with AWS CLI
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: eu-west-1
Default output format [None]: json

# Export as environment variable
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_DEFAULT_REGION=eu-west-1
```

Now configure the remote state. This command will automatically detect if there is a current state file on your local disk. If there is one available on your local disk, it will upload that state file to S3. When there is a file on S3, it will download that file to your local disk. S3 state files are saved in the `.terraform` folder.

The `key` value is how you want to name your state file in the AWS S3 bucket. You can choose this freely, as long as the key is unique for every Terraform project.

```bash
terraform remote config -backend=s3 -backend-config="bucket=mybucketname" -backend-config="key=nam_of_key_file"
```

# Using remote state in other Terraform projects

You can use a state file and its [outputs](https://terraform.io/docs/configuration/outputs.html) with other projects.

Define some outputs of values you want to use in other projects.

````
output "vpc_id" {
  value = "${aws_vpc.main.id}""
}

output "proxy_subnets" {
  value = "${join(",", aws_subnet.proxy_subnets.*.id)}"
}
```

After a terraform apply run you will see the following.

```
Outputs:
  proxy_subnets      = subnet-1232ae34,subnet-abc41234,subnet-abc1e399
  vpc_id             = vpc-1232ae34
```

In a new terraform project you can do the following, to use these two outputs.

```
provider "aws" {
  access_key  = "${var.access_key}"
  secret_key  = "${var.secret_key}"
  region = "${var.aws_region}"
}

resource "terraform_remote_state" "remote_state" {
    backend = "s3"
    config {
        bucket = "mybucketname"
        key = "nam_of_key_file"
    }
}

module "app" {
  source = "modules/blue-green"
  name = "app"
  vpc_id = "${terraform_remote_state.remote_state.output.vpc_id}"
  subnets = "${terraform_remote_state.remote_state.output.app_subnets}"
}
```

_Little side note: To use outputs of modules in other Terraform projects you will also need to define those outputs in your main terraform file. For example:_

```
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
```

# Conclusion

It is true what Hashicorp [says](https://terraform.io/docs/state/remote.html): Putting your state somewhere remote (S3, Atlas,Consul) improves safety and teamwork and I see a lot of advantages for the Terraform remote state. I hope that sometime in the near future we can configure the remote state through config file instead of command line, see the [following GitHub issue.](https://github.com/hashicorp/terraform/issues/1964)

My current blue/green Terraform deployment is mostly based on [@phinze](https://twitter.com/phinze) [example](https://github.com/phinze/tf-bluegreen-asg-deployment).
