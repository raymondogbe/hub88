### Project description and explanation

---

### Terrform-Ansible Project

This project uses **Terraform** to provision AWS infrastructure and **Ansible** to configure services like the Nginx on EC2 instances. The infrastructure includes a **Virtual Private Cloud (VPC)**, private and public subnets across 2 Availability Zones (AZs), EC2 instances, a **Bastion Host (jump host)**, **S3 bucket** for statefiles and logs, an **Application Load Balancer (ALB)**, and Dockerized **Nginx** services running on each EC2 instance. Additionally, Docker logs are delivered to AWS **CloudWatch** for centralized logging and monitoring.

---

### Table of Contents

1. **Overview**
2. **Prerequisites**
3. **Setup Instructions**
4. **Terraform Setup**
5. **Ansible Setup**
6. **Detailed Explanation**
   - Terraform Infrastructure
   - Ansible Configuration
   - Jenkins Integration
7. **Source of Information**
8. **Suggested Improvements**

---

### Overview

This project automates the setup and configuration of AWS infrastructure using **Terraform** and **Ansible**. The architecture includes:

- A **VPC** with private and public subnets across 2 Availability Zones (AZs).
- Three **EC2 instances** for application hosting.
- A **Jumphost** (Bastion Host) for secure access to the private instances.
- An **Application Load Balancer (ALB)** that distributes traffic across EC2 instances.
- **IAM** roles and policies for EC2 instances and CloudWatch access.
- **S3 Bucket** For remote storage of state files and other logs
- **Dockerized Nginx instances** running on each EC2 instance with different `index.html` files.
- **CloudWatch logging** for Docker container logs.


---

### Key Technologies

- **Terraform** for Infrastructure as Code (IaC).
- **Ansible** for server/service configuration.
- **Docker** for containerization of the Nginx service.
- **AWS** EC2, VPC, ALB, S3, IAM, and CloudWatch.

---

### Prerequisites

Ensure you have the following tools installed on your machine:

- **Terraform**: For provisioning AWS infrastructure.
- **Ansible**: For configuration management and deployment.
- **AWS CLI**: For managing AWS resources.
- **Docker**: For containerization of applications.
- **Jenkins** (optional): For automating the Terraform and Ansible workflow. in a CICD workflow

You also need:

- An **AWS account** with sufficient permissions to manage EC2 instances, VPCs, IAM roles, and CloudWatch logs.
- AWS credentials configured locally or through environment variables.

---

### Setup Instructions

#### Terraform Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/hub88.git
   cd hub88
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Plan the Terraform Execution:
   ```bash
   terraform plan -out=tfplan
   ```

4. Apply the Terraform Plan:
   ```bash
   terraform apply --auto-approve
   ```
   This will create the necessary resources, such as the VPC, subnets, EC2 instances, ALB, IAM roles, and policies, S3 buckets, cloudwatch....

#### Ansible Setup

1. **Inventory Generation**: Terraform dynamically generates the Ansible inventory file (`inventory.ini`) based on the infrastructure it provisions.

2. **Ansible Configuration**: The Ansible configuration (`ansible.cfg`) is generated automatically by Terraform and is tailored to use the Bastion Host’s IP for SSH access.

3. **Run Ansible Playbook**: Once Terraform provisions the infrastructure, the Ansible playbook is automatically executed by Terraform through the `null_resource` with a remote-exec provisioner. This will:
   - Install Docker and Nginx on each EC2 instance.
   - Deploy an Nginx Docker container on each instance with a unique `index.html` file.

To run manually:
```bash
ansible-playbook -i inventory.ini playbook.yml
```

#### Docker Logs to CloudWatch

1. **Docker Logging Driver**: Configure the `awslogs` driver for Docker containers in the playbook to ensure logs are pushed to CloudWatch.

2. **CloudWatch Configuration**: Ensure the EC2 instances have appropriate IAM roles to send logs to CloudWatch.

---

### Detailed Explanation

#### Terraform Infrastructure

1. **VPC**: A custom VPC is created with a CIDR block of `10.161.0.0/24`. This ensures that the network is logically isolated, providing flexibility to create subnets and configure routing and security.

2. **Subnets**: Private and public subnets are created following best practices for high availability and fault tolerance. These subnets are distributed across two Availability Zones (AZs) to ensure redundancy.

   - **Private Subnets**:
     - `10.161.0.153`
     - `10.161.0.155`
     - `10.161.0.149`

   These subnets are located in different AZs for high availability. By placing instances in private subnets, they are shielded from direct internet access, enhancing security.

3. **EC2 Instances**: Three EC2 instances are provisioned in the private subnets, and one Bastion Host is created in a public subnet for secure access to the private instances.

   - **Bastion Host**: This is the only instance with public access, acting as a jump server to securely SSH into the private EC2 instances.

   - **Private EC2 Instances**: These are isolated in private subnets, preventing direct access from the internet and improving security.

4. **Application Load Balancer (ALB)**: The ALB distributes incoming traffic across the EC2 instances on port 80. It performs health checks to ensure that traffic is only routed to healthy instances.

5. **IAM Roles**: Custom IAM roles are created to allow EC2 instances to interact with CloudWatch logs securely, enabling centralized logging for troubleshooting and monitoring.

#### Ansible Configuration

The Ansible playbook automates the installation of Docker and Nginx on the EC2 instances. It also ensures that each instance serves a unique `index.html` page through Docker containers. The following was done to simplify the process:

- **Automating Ansible Installation**: Initially, I considered running the Ansible playbook locally, but this would require each user to install Ansible. To solve this, I used Terraform to provision the Bastion Host and ensure that Ansible runs directly on it, eliminating the need for users to set up Ansible locally.

- **Python and Ansible Fixes**: Since the EC2 instances initially had Python 2.7, I upgraded it to Python 3. I also configured Ansible to use Python 3 by default (`interpreter_python = /usr/bin/python3`).

---

### Testing Experience

While working on the project, I encountered several issues:

- **Terraform Delay**: During one of the runs, I noticed a significant delay in Terraform execution. By enabling debug mode (`terraform apply -debug`), I discovered that the process was stuck due to a permission problem. Specifically, Terraform was trying to move my SSH key to the specified location, but it didn't have the proper permissions. After identifying the issue, I adjusted the permissions, and the problem was resolved.

- **Ansible Failures**: When running Ansible, I faced multiple failures. By increasing the verbosity (`ansible-playbook -vvv`), I was able to trace the issue to Ansible not properly recognizing my SSH key. Once I addressed the SSH configuration, the playbook ran smoothly.
- Some other challanges were
1. using Amazon linux2, I realized that I was unable to run Ansible as it kept giving me issues. I had to switch to Ubuntu.
2. Using t2.micro since it was free, I realized that I had issues automated the deployment. I guess due to its size. Upon using t2.medium, I was able to seemlessly run the automation.
3. I had a lot of network issues that made me to debugg endlessly. Network issue apparently was as a result of the unstable mobile internet that I had to use.

---
### DYNAMODB SETUP
1.   Sign in to AWS Console: Go to: https://console.aws.amazon.com
2.   Sign in using your credentials
3.   In the search bar, type DynamoDB and select it from the drop down menu
4.   From the dashboard, click on **"create table"** button
5.   Type in a table name of preference. This table name will be inserted into our terraform remote backend configuration code
6.   Type in **"LockID"** as the partition key. LockID is used to implement a distributed locking mechanism, particularly when managing Terraform state since this is what it is needed for.
7.   Scroll down and click on **"create table"** button
8.   Your table would be obvious on the Dashboard

Use your credentials to log in.
### Jenkins Setup
1. Launch or create another ec2-instance for Jenkins. Follow instructions in this link https://www.techtarget.com/searchcloudcomputing/tutorial/How-to-create-an-EC2-instance-from-AWS-Console
2. Install Java 17 and terraform
3. Install docker and jenkins
   -   For Terraform installation and configuration, click on this link https://www.cherryservers.com/blog/install-terraform-ubuntu
   -   For Docker installation and configuration, click on this link https://www.cherryservers.com/blog/install-docker-ubuntu-22-04
   -   For Jenkins installation and configuration, click on this link https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
   -   Once jenkins is done installing, use the ec2-instance public IP and the jenkins port number 8080 to access jenkins. http://instanceip:8080
   -   ![image](https://github.com/user-attachments/assets/2f87d80a-3330-4c3a-a13d-1b726a0006e2)
   -   Unlock jenkins by entering the Admin password that can be retrieved using the path in the screenshot above
   -   Create a user by entering username, password and name in the space provided
   -   Install all the suggested plugins
4. Configure your jenkins and install the different plugins like the AWS credentials plugin...
   -   From the jenkins dashboard, click on manage jenkins, click on manage plugins, from the page that appears, click on available plugin and type the plugin you want to install in the search bar.
   -   Use same method to install "pipepline stage view" plugin.
   -   Install "docker pipeline" plugin with same method
5. Configure your credentials using the AWS key and secret
   -   From the jenkins dashboard, click on manage jenkins, click on credentials, click on global and insert your credentials using AWS credentials.
   -   You can also use the secret text to store your AWS access key and secret key. You can get more information here: https://medium.com/novai-devops-101/configuring-jenkins-credentials-for-deployment-to-ubuntu-host-using-scp-and-ssh-43b962b7eb67
6. Configure your git token into jenkins for communication
   - You can get your git token from github. Follow this instruction link https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
   - Github token should be added to credentials in jenkins, same as it was done for others as above
7. From the jenkins dashboard, click on "new item" button in order to create a new job
8. Enter a item name, which is the name for the job and select "pipeline"
9. Copy the jenkinsfile in this repo into your pipeline script and save. Make sure that the credentials name is same with the one in the jenkinsfile script
10. To run jenkins, click on **"Build now"** from the dashboard.
11. For errors, check the console logs.
   
### Jenkins Integration

Jenkins automates the entire CI/CD pipeline, ensuring seamless provisioning and deployment:

1. **Checkout Code**: The pipeline pulls the latest code from the Git repository.
2. **Terraform Init/Plan/Apply**: These stages handle Terraform initialization, planning, and resource provisioning.
3. **Terraform Destroy**: This cleans up resources after testing or when no longer needed.

Jenkins ensures that the process is fully automated, reducing human error and improving workflow efficiency.

---

### Source of Information

To build this solution, I relied on the following resources:

- **Google**: Terraform documentation and other online resources.
- **Stackoverflow**: This was very resourceful as I was able to get some written codes that I only needed to tweak.
- **Terraform Documentation**: [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- **YouTube**: Videos on Terraform best practices.
- **Manuals**: Official documentation for Terraform and Ansible.
  - [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
  - [Ansible AWS Collection](https://docs.ansible.com/ansible/latest/collections/amazon/aws/index.html)

These resources were instrumental in shaping the infrastructure design and ensuring that the environment was properly configured for seamless deployment and management.

---

### Suggested Improvements

- **Auto Scaling**: To enhance availability and fault tolerance, adding **auto-scaling** capabilities to automatically adjust the number of EC2 instances based on traffic load could make the system more resilient and cost-efficient. With auto-scaling, new EC2 instances can be spun up when traffic increases, and unnecessary instances can be terminated when demand decreases.
  
Running Terraform from the command line was successful
![image](https://github.com/user-attachments/assets/32046a17-9f2f-4537-b097-14d7216ffeb3)


curl into the instances in the private subnets

![image](https://github.com/user-attachments/assets/eb7655ad-1bbd-49f0-9ee9-09c558a2ae08)


Instances in the ALB were healthy
![image](https://github.com/user-attachments/assets/ebc3a34f-ec40-48ea-b4a5-3c67614b17c8)

Jenkins deployment was successful
![image](https://github.com/user-attachments/assets/c0937633-6704-4b7e-84df-6a84aa1ba917)
![image](https://github.com/user-attachments/assets/1b1ab6c2-bba5-44a0-91ae-c59088e3fdba)
![image](https://github.com/user-attachments/assets/df9e51d9-ab96-4102-b6f0-78ccadec7784)

Cloudwatch logs
![image](https://github.com/user-attachments/assets/2b818f6d-4cf2-46ce-9650-edcd95d7bef4)

Running Instances
![image](https://github.com/user-attachments/assets/2a01690c-6ec6-4adf-b4dd-3763e20a1c6f)





