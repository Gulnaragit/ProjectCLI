### README for creation of AWS VPC, EC2 Instance using AWS CLI.

This bash script automates the process of creating a custom VPC, subnets, route tables, a NAT gateway, security groups, and an EC2 instance using the AWS CLI.

#### Prerequisites:
1. AWS CLI must be installed and configured on your local machine.
2. Ensure that you have proper IAM permissions to create and manage VPC, subnets, route tables, security groups, NAT gateways, Elastic IPs, and EC2 instances.
3. You should have an SSH key (`id_rsa.pub`) available in your local `~/.ssh/` directory for importing into AWS.

#### Features:
- **VPC Creation**: Creates a custom VPC named "Kaizen" with a CIDR block of `10.0.0.0/16`.
- **Subnets**: Creates three subnets across different availability zones (`us-east-1a`, `us-east-1b`, and `us-east-1c`).
  - `Subnet1` (Public Subnet) in AZ `us-east-1a`.
  - `Subnet2` (Private Subnet) in AZ `us-east-1b`.
  - `Subnet3` (Private Subnet) in AZ `us-east-1c`.
- **Internet Gateway**: Creates and attaches an Internet Gateway to the VPC.
- **Route Tables**:
  - Public route table for the public subnet, associated with the Internet Gateway.
  - Private route table for the private subnet, associated with the NAT Gateway.
- **Security Group**: Creates a security group allowing HTTP (port 80) and SSH (port 22) traffic.
- **Elastic IP**: Allocates an Elastic IP.
- **NAT Gateway**: Creates a NAT Gateway for the private subnet with above allocated Elastic IP
- **EC2 Instance**: Launches a t2.micro EC2 instance in the public subnet with SSH access via a key pair.

#### Usage:
1. **Run the Script**:
   - Add executable permissions for the script
     chmod +x aws-cli.sh
   - Execute the script:
     ./aws-cli.sh

2. **Output**:
   - The NAT Gateway takes time to become available, so the script pauses for 60 seconds during execution to ensure its availability.
   - The script outputs the public IP of the EC2 instance created in the public subnet.

3. **Additional step to demonstrate the SSH feature works**:
   - Get the Public IP that was printed out and SSH to that Instance using your local terminal.

4. **Additional step to demonstrate that NAT gateway was correctly configured**:
   - Get the Public key of the above EC2 Instance.
   - Import the Public key to AWS Keypair, using AWS Console. 
   - Create an EC2 Instance in AWS Console with above Keypair, inside your custom VPC, in Private subnet and with security group that has port 22 open.
   - Get the Private IP of the above Instance in private subnet, and from your Instance that is public subnet SSH to it.
   - Confrim it has access to the web, by pinging google.com
  

#### Key Points:
- **NAT Gateway**: The script sets up a NAT Gateway to allow instances in the private subnet to access the internet.
- **SSH Key Import**: It imports your local SSH public key (`~/.ssh/id_rsa.pub`) into AWS to allow SSH access to the EC2 instance.
- **Tag Specifications**: Tags are used along the way to ensure future retrieval of any components to edit or delete using AWS CLI.
