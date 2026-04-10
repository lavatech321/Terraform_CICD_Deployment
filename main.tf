
resource "aws_key_pair" "mykey" {
    key_name = "terraform-ansible-key1"
    #public_key = file("C:/Users/username/.ssh/id_rsa.pub")
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "jenkins-allow" {
    name = "allow-jenkins"
    description = "Allow only jenkins port"
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ssh-allow" {
    name = "allow-ssh-ansible"
    description = "Allow only ssh port"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "servers" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "m7i-flex.large"
    key_name = aws_key_pair.mykey.key_name
    root_block_device {
	  volume_size           = 40
	  volume_type           = "gp3"
	  delete_on_termination = true
	  encrypted             = true
    }
    vpc_security_group_ids = [
  aws_security_group.ssh-allow.id,
  aws_security_group.jenkins-allow.id
]


    connection {
                type     = "ssh"
                user     = "ec2-user"
                private_key = file("~/.ssh/id_rsa")
                host = aws_instance.servers.public_ip
        }
	provisioner "file" {
    		source      = "configure-jenkins.sh"
		destination = "/home/ec2-user/code.sh"
  	}
	provisioner "remote-exec" {
  inline = [
	"sudo yum update -y",
	"sudo yum install git -y",
	"sudo yum install java-17-amazon-corretto -y",

    # Install Jenkins
    "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
    "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
    "sudo yum install jenkins -y",
    #"sudo systemctl enable jenkins",

    # Configure jenkins
    "sudo chmod +x /home/ec2-user/code.sh",
    "bash /home/ec2-user/code.sh",
    "bash /home/ec2-user/code.sh",

  ]
}
}

output "EC2-Instance-access-details" {
	value = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.servers.public_ip} \n"
}

output "Jenkins-UI" {
	value = "http://${aws_instance.servers.public_ip}:8080 \n"
}

