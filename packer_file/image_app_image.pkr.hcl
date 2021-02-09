source "amazon-ebs" "my_image_app_ebs" {
  ami_description             = "Contains the necessary code and environment for my-image-app"
  ami_name                    = "my-image-app"
  instance_type               = "t2.micro"
  region                      = "eu-west-1"
  source_ami                  = "ami-0fc970315c2d38f01"  // Amazon Linux 2
  associate_public_ip_address = true
  ssh_username                = "ec2-user"
  ssh_keypair_name            = "work_laptop_aws"
  ssh_private_key_file        = "C:/Users/alec.barns-graham/.ssh/work_laptop_aws.pem"
}

build {
  sources = ["source.amazon-ebs.my_image_app_ebs"]

  provisioner "shell" {
    inline = ["mkdir /home/ec2-user/my-app/"]
  }

  provisioner "file" {
    destination = "/home/ec2-user/my-app/my_app.py"
    source      = "./my-app/my_app.py"
  }

  provisioner "file" {
    destination = "/home/ec2-user/my-app/requirements.txt"
    source      = "./my-app/requirements.txt"
  }

  provisioner "file" {
    destination = "/home/ec2-user/Dockerfile"
    source      = "./Dockerfile"
  }

  provisioner "shell" {
    inline = ["mkdir /home/ec2-user/my-app/app"]
  }

  provisioner "file" {
    destination = "/home/ec2-user/my-app/app/__init__.py"
    source      = "./my-app/app/__init__.py"
  }

  provisioner "file" {
    destination = "/home/ec2-user/my-app/app/routes.py"
    source      = "./my-app/app/routes.py"
  }

  provisioner "shell" {
    script = "./initial_setup.sh"
  }

  provisioner "shell" {
    inline = ["sudo docker build --tag my-image-app-image --file=/home/ec2-user/Dockerfile /home/ec2-user/"]
  }
}

