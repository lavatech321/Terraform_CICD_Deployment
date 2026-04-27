# Terraform Jenkins Deployment ( on AWS EC2)

---

# Technologies Used

| Layer             | Technology                                |
| ----------------- | ----------------------------------------- |
| Infrastructure    | Terraform, AWS EC2 (Amazon Linux)         |
| CICD			    | Jenkins         |

---

# How to Run

## Step 1: Initialize Terraform

```bash
git clone https://github.com/lavatech321/Terraform_CICD_Deployment.git
terraform init
```

Login into Jenkins using username and password shown below:

username: admin
password: admin123

---

## Step 2: Apply Configuration

```bash
terraform apply --auto-approve
```
