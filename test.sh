#!/bin/bash


vpc_cidr="10.0.0.0/16"
subnet_cidr1="10.0.1.0/24"
subnet_cidr2="10.0.2.0/24"
subnet_cidr3="10.0.3.0/24"
region="us-east-1"
az1="us-east-1a"
az2="us-east-1b"
az3="us-east-1c"


# Create custom VPC in AZ "us-east-1" named "Kaizen"
vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --region $region --tag-specifications 'ResourceType=vpc, Tags=[{Key=Name,Value=kaizen}]' --query Vpc.VpcId --output text)

# Create first subnet in AZ "us-east-1a" named "Subnet1"
sub1=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr1 --availability-zone $az1 --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name,Value=Subnet1}]' --query Subnet.SubnetId --output text)

# Create second subnet in AZ "us-east-1b" named "Subnet2"
sub2=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr2 --availability-zone $az2 --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name,Value=Subnet2}]' --query Subnet.SubnetId --output text)

# Create third subnet in AZ "us-east-1c" named "Subnet3"
sub3=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block $subnet_cidr3 --availability-zone $az3 --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name,Value=Subnet3}]' --query Subnet.SubnetId --output text)

# Create Internet gateway named "custom-igw"
igw_id=$(aws ec2 create-internet-gateway --region $region --tag-specifications 'ResourceType=internet-gateway, Tags=[{Key=Name,Value=Custom-igw}]' --query InternetGateway.InternetGatewayId --output text)

# Attach Internet gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id --region $region --query InternetGateway.InternetGatewayId --output text > /dev/null

# Create Public route table and assign to Kaizen VPC
public_rtb_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications 'ResourceType=route-table, Tags=[{Key=Name,Value=Custom-rtb}]' --query RouteTable.RouteTableId --output text)

# Create Private route table and assign to Kaizen VPC
private_rtb_id=$(aws ec2 create-route-table --vpc-id $vpc_id --tag-specifications 'ResourceType=route-table, Tags=[{Key=Name,Value=Custom-rtb}]' --query RouteTable.RouteTableId --output text)

# Attach route table to Internet Gateway
aws ec2 create-route --route-table-id $public_rtb_id --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id > /dev/null 

# Associate public subnet to route table
aws ec2 associate-route-table --subnet-id $sub1 --route-table-id $public_rtb_id > /dev/null

# Create security group
sg_id=$(aws ec2 create-security-group --group-name EC2SecurityGroup --description "Project Security Group" --vpc-id $vpc_id --tag-specifications 'ResourceType=security-group, Tags=[{Key=Name,Value=Custom-sg}]' --query GroupId --output text)

# Open HTTP traffic port 80 for security group
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 80 --cidr 0.0.0.0/0 > /dev/null

# Open SSH traffic port 22 for security group
aws ec2 authorize-security-group-ingress --group-id $sg_id --protocol tcp --port 22 --cidr 0.0.0.0/0 > /dev/null

# Allocate Elastic IP
elastic_ip=$(aws ec2 allocate-address --domain $vpc_id --tag-specifications 'ResourceType=elastic-ip, Tags=[{Key=Name,Value=elastic-ip}]' --query AllocationId --output text)

# Create NAT gateway associate it with above Elastic Ip and Public subnet1
nat_gtw_id=$(aws ec2 create-nat-gateway --subnet-id $sub1 --allocation-id $elastic_ip --query NatGateway.NatGatewayId --output text)

echo "Stoping the execution of the code for 60seconds for the NAT gateway to become available"
sleep 60
echo "Now continuing the execution of the code..."

# Tag NAT Gateway
aws ec2 create-tags --resources $nat_gtw_id --tags Key=Name,Value=custom-natgw

# Attach route table to NAT Gateway
aws ec2 create-route --route-table-id $private_rtb_id --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $nat_gtw_id > /dev/null 

# Associate private subnet to route table
aws ec2 associate-route-table --subnet-id $sub2 --route-table-id $private_rtb_id > /dev/null

# Import public key of my local machine to AWS console
aws ec2 import-key-pair --key-name "ProjectKeyPair" --public-key-material fileb://~/.ssh/id_rsa.pub > /dev/null

# Create EC2 instance in public Subnet1
ec2_id_1=$(aws ec2 run-instances --image-id ami-0ebfd941bbafe70c6 --count 1 --instance-type t2.micro  --security-group-ids $sg_id --subnet-id $sub1 --associate-public-ip-address --key-name 'ProjectKeyPair' --tag-specifications 'ResourceType=instance, Tags=[{Key=Name, Value=Public-CLI-Ec2}]' --query Instances[0].InstanceId --output text)

# Get the Public IP of the public Instance
public_ip=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress[]' --filter 'Name=tag:Name, Values=Public-CLI-Ec2' --output text)

echo Public Ip of the Instance: $public_ip
