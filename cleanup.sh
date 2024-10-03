#!/bin/bash 


# Find EC2 Instance Ids for Public and Private Instances
public_ec2=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId[]' --filter 'Name=tag:Name, Values=Public-CLI-Ec2' --output text)
private_ec2=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId[]' --filter 'Name=tag:Name, Values=Private-CLI-Ec2' --output text)


# Terminate EC2 Instance
aws ec2 terminate-instances --instance-ids $public_ec2 
aws ec2 terminate-instances --instance-ids $private_ec2

echo "Will continue deleting after sleep of 60seconds"
sleep 60 

# Find NAT gateway Id 
natgw_id=$(aws ec2 describe-nat-gateways --filter 'Name=tag:Name, Values=custom-natgw)



# --query' 'NatGateways[*].NatGatewayId[]' --output text)
# Find Allocation Id or Elasric IP
#aws ec2 describe-addresses --filters 'Name=tag:Name, Values=elastic-ip' --query 'addresses[*] allocationId[]' --output text 



# Find VPC Id need to be deleted
#aws ec2 describe-vpcs --query 'Vpcs[?contains(Tags[?Key==`Name`].Value[], `MyVPC`) == `true`].[VpcId]'


# Delete VPC, it will aslo delete subnets, igw, route tables & security group
#aws ec2 delete-vpc --vpc-id 
