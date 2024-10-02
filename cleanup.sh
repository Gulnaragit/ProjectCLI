#!/bin/bash 


# Delete EC2 Instance
aws ec2 terminate-instances --instance-ids i-0599afcd80b3f7660

# Delete VPC, it will aslo delete subnets, igw, route tables & security group
aws ec2 delete-vpc --vpc-id vpc-0c9e6de48a634dafe
