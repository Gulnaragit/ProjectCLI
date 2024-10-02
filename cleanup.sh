#!/bin/bash 


# Delete EC2 Instance
aws ec2 terminate-instances --instance-ids 


# Delete VPC, it will aslo delete subnets, igw, route tables & security group
#aws ec2 delete-vpc --vpc-id 
