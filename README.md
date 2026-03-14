# CI/CD Pipeline: Deploying a Web App with Jenkins, Docker, Terraform, and AWS

This repository demonstrates a complete, automated CI/CD pipeline. It takes a simple HTML website, packages it into a Docker container, pushes it to Docker Hub, and uses Terraform to automatically provision an AWS EC2 instance that pulls and runs the container.

## 🚀 Architecture Overview
1. **GitHub**: Hosts the source code.
2. **Jenkins**: The CI/CD server that orchestrates the workflow.
3. **Docker**: Packages the application into a portable, lightweight container.
4. **Docker Hub**: The container registry where the built image is stored.
5. **Terraform**: Infrastructure as Code (IaC) tool used to provision the AWS environment.
6. **AWS (EC2 & Security Groups)**: The cloud provider hosting the final web server.

---

## 📋 Prerequisites & Jenkins Server Setup

To run this pipeline successfully, your Jenkins server (typically an EC2 instance) must have Git, Docker, and Terraform installed.

### 1. Install Dependencies on the Jenkins Server
SSH into your Jenkins EC2 instance and run the following commands (for Amazon Linux/RHEL/CentOS):

**Install Git:**
```bash
sudo yum update -y
sudo yum install git -y

```

**Install Docker & Grant Permissions:**

```bash
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
# Grant Jenkins permission to run Docker commands
sudo usermod -aG docker jenkins 
sudo systemctl restart jenkins

```

**Install Terraform:**

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo [https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo](https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo)
sudo yum -y install terraform

```

---

## ⚙️ Jenkins Configuration Steps

1. **Add Credentials in Jenkins:**
* Navigate to **Manage Jenkins** -> **Credentials** -> **System** -> **Global credentials**.
* Add `docker-hub-credentials` (Type: Username with password).
* Add `aws-access-key` (Type: Secret text).
* Add `aws-secret-key` (Type: Secret text).
* *(If your GitHub repo is private)* Add your GitHub Personal Access Token as a Username with Password.


2. **Create the Pipeline:**
* Create a new **Pipeline** job named `Adnan-Deployment-Pipeline`.
* Under the **Pipeline** section, choose **Pipeline script from SCM**.
* Select **Git** and paste your repository URL.
* Set the Script Path to `Jenkinsfile`.


3. **Run the Build:**
* Click **Build Now**.
* Once successful, check the Console Output. Scroll to the bottom to find your new server's `public_ip` outputted by Terraform.
* Paste the IP into your browser to view your successfully deployed site! *(Note: It may take 1-2 minutes for the AWS server to fully boot and pull the Docker image).*



---

## 🛠️ Common Errors & Troubleshooting

During the development of this pipeline, several common roadblocks were encountered and resolved. If your pipeline fails, check these fixes:

### 1. Jenkins Node Offline / "Waiting for next available executor"

**The Issue:** Jenkins requires at least 1GB of free space in the `/tmp` directory. On smaller EC2 instances, Linux sometimes mounts `/tmp` to a limited RAM disk (`tmpfs`), causing Jenkins to take the node offline to prevent a crash.
**The Fix:** SSH into your Jenkins server and move `/tmp` to your main hard drive:

```bash
sudo systemctl stop jenkins
sudo umount /tmp
sudo systemctl mask tmp.mount
sudo systemctl start jenkins

```

### 2. Git Error: `couldn't find remote ref refs/heads/master`

**The Issue:** GitHub's default branch name is `main`, but Jenkins looks for `master` by default.
**The Fix:** In your Jenkins job configuration, under the **Pipeline** section, change the "Branches to build" specifier from `*/master` to `*/main`.

### 3. Docker Push Error: `denied: requested access to the resource is denied`

**The Issue:** Docker Hub blocks pushes if the image tag username does not perfectly match the username you used to log in.
**The Fix:** Ensure the `DOCKER_IMAGE` environment variable in your `Jenkinsfile` and the `docker run` command in your `main.tf` file use your exact Docker Hub username.

### 4. Terraform Error: `The specified instance type is not eligible for Free Tier`

**The Issue:** Some newer AWS accounts or student accounts do not support `t2.micro` as the default Free Tier instance.
**The Fix:** Update the `main.tf` file to use `t3.micro` instead of `t2.micro` in the `aws_instance` resource block.

```

```
