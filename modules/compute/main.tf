#-------- compute/main.tf --------
#===================================
provider "aws" {
  region = var.region
}

#Get Linux AMI ID using SSM Parameter endpoint
#===============================================
data "aws_ssm_parameter" "webserver-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for connect to the EC2 instance
#==================================================
resource "aws_key_pair" "aws-key" {
  key_name = "webserver"
  public_key = file(var.ssh_key_public)
}

# Template file is deprecated and is replaced with Ansible
#==========================================================
#data "template_file" "user-init" {
#  template = file("${path.module}/userdata.tpl")
#}

#Create and bootstrap webserver
#==============================
resource "aws_instance" "webserver" {
  ami                           = data.aws_ssm_parameter.webserver-ami.value
  instance_type                 = "t2.micro"
  associate_public_ip_address   = true
  vpc_security_group_ids        = [var.security_group.id]
  subnet_id                     = var.subnets
  user_data                     = data.template_file.user-init.rendered
  key_name                      = aws_key_pair.aws-key.key_name
  tags = {
    Name = "bf_webserver"
  }
  
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file(var.ssh_key_private)
    host = self.public_ip
  }

  # Copy the file from local machine to EC2
  provisioner "file" {
    source      = "install_apache.yaml"
    destination = "install_apache.yaml"
  }

  #Execute a script on a remote resource
  provisioner "remote-exec" {
    inline =[
      "sudo yum update -y && sudo amazon-linux-extras install ansible2 -y",
      "sleep 60s",
      "ansible-playbook install_apache.yaml"
    ]
    
  }
}