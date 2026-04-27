
resource "aws_key_pair" "mykey" {
    key_name = "terraform-ansible-key2"
    #public_key = file("C:/Users/username/.ssh/id_rsa.pub")
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "jenkins-allow" {
    name = "allow-jenkins-ubuntu"
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
    name = "allow-ssh-ansible-ubuntu"
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

data "aws_ami" "ubuntu_22" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "servers" {
    ami = data.aws_ami.ubuntu_22.id
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
                user     = "ubuntu"
                private_key = file("~/.ssh/id_rsa")
                host = aws_instance.servers.public_ip
        }
	provisioner "file" {
    		source      = "configure-jenkins.sh"
		destination = "/home/ubuntu/code.sh"
  	}
	provisioner "remote-exec" {
inline = [
	"sudo apt update -y",
	"sudo apt install -y git",

	# Install Java (required for Jenkins)
	"sudo apt install -y openjdk-21-jdk",
	"wget https://pkg.jenkins.io/debian-stable/binary/jenkins_2.462.3_all.deb",
	"sudo dpkg -i jenkins_2.462.3_all.deb",
	"sudo apt --fix-broken install -y",
	"sudo systemctl start jenkins",
	"sudo systemctl enable jenkins",
]
}
}

output "EC2-Instance-access-details" {
	value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.servers.public_ip} \n"
}

output "Jenkins-UI" {
	value = "http://${aws_instance.servers.public_ip}:8080 \n"
}
output "Jenkins-Credentials" {
	value = "Username: admin \n Password: admin123"
}

