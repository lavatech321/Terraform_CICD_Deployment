# Terraform Jenkins Deployment on AWS EC2

This project provisions an AWS EC2 instance using Terraform and automatically installs and configures Jenkins for CI/CD usage.

---

## Technologies Used

| Layer          | Technology                        |
| -------------- | --------------------------------- |
| Infrastructure | Terraform, AWS EC2 (Amazon Linux) |
| CI/CD          | Jenkins                           |

---

## Project Setup & Usage

### Step 1: Clone the Repository

```bash
git clone https://github.com/lavatech321/Terraform_CICD_Deployment.git
cd Terraform_CICD_Deployment
```

---

### Step 2: Configure AWS Credentials

Open the `terraform.tfvars` file and replace with your AWS credentials:

```hcl
aws_access_key = "YOUR_ACCESS_KEY"
aws_secret_key = "YOUR_SECRET_KEY"
region         = "ap-south-1"
```

⚠️  Make sure:

* You use a valid AWS IAM user
* The user has permissions for EC2, security groups, and key pairs

---

### Step 3: Initialize Terraform

```bash
terraform init
```

---

### Step 4: Apply Terraform Configuration

```bash
terraform apply --auto-approve
```

This will:

* Create an EC2 instance
* Install Jenkins automatically
* Configure Jenkins with a default admin user

---

### Step 5: Access Jenkins

Once deployment is complete:

* Open your browser:

  ```
  http://<EC2-PUBLIC-IP>:8080
  ```

* Login credentials:

  ```
  Username: admin
  Password: admin123
  ```

---

## 📌 Notes

* Ensure port **8080** is open in the security group
* Wait 1–2 minutes after deployment for Jenkins to fully start
* You can modify instance type and region in `vars.tf` or `terraform.tfvars`

---

## Project Purpose

This project demonstrates:

* Infrastructure as Code using Terraform
* Automated Jenkins setup on AWS
* Basic CI/CD environment provisioning

---

## 🧹 Cleanup (Important)

To destroy the infrastructure and avoid AWS charges:

```bash
terraform destroy --auto-approve
```

---

## ✅ Outcome

After completion, you will have:

* A running EC2 instance
* Jenkins installed and ready
* A base setup for CI/CD pipelines

---

