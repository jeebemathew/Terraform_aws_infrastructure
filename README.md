# Terraform_aws_infrastructure : Terraform is a tool made by Hashicorp for building, changing, and versioning infrastructure safely and efficiently

## Requirement:
- Terraform
- Aws IAM account with programmatic access (here, I used a separate file 'provider.tf' to save the login details'

Terraform can manage existing and popular service providers ( aws, azure, Google cloud) as well as custom in-house solutions. Let me just explain the work which are going to complete using this code.
First it will create a new VPC in aws and one public subnet and one private subnet using the new VPC. Next creating an Internet gateway which will be assigned to the public subnet and a Nat gateway which will be assigned to the private subnet.
Next step, we need to create an elastic IP for the nat gateway and associate it with the created nat gateway. Then we will create 2 ec2 instance. First one will be the webserver which will be created under the public subnet.
The next one will be database server which will create under private subnet. So that these two instances can communicate each other but no other servers can communicate with the database from outside since there won't be any public IP assigned to the database server.
Webserver can communicate with the Database server using the private IP

## Execution

``````

#terraform validate   - syntax check 

#terraform plan - Creating an execution plan ( to check what will get installed before running it)

# terraform apply - Applying

# terraform destroy - Destroying what we have applied through terrafrom apply

We can also use -auto-approve while applying.
# terraform apply -auto-approve

```````
