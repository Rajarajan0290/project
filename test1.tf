provider "aws" {
    region  = "us-east-2"
}

resource "aws_instance" "examples"{
  ami           = "ami-00c4b877294e28e09"
  instance_type = "t2.micro"
  key_name      = "raja_devops"

tags            = {
    Name        = "nodeJS Server"
    Environment = "Test"
}

 connection {
        type     = "ssh"
        user     = "root"
        password = "password"
        host     =  "${self.public_ip}"
     }

provisioner "local-exec" {
    command = "echo ${aws_instance.examples.public_ip} > /home/centos/public_ips.txt"
  }
  provisioner "file" {
    source      = "/home/centos/public_ips.txt"
    destination = "/home/centos/public_ips.txt"
  }

  provisioner "file" {
    source      = "/home/centos/app.js"
    destination = "/home/centos/app.js"
  }

   provisioner "file" {
    source      = "/home/centos/app.service"
    destination = "/home/centos/app.service"
  }
  provisioner "file" {
    source      = "/home/centos/jode.sh"
    destination = "/home/centos/jode.sh"
  }
provisioner "remote-exec" {
    
        inline      = [
           "chmod +x /home/centos/jode.sh",
           "sudo sh /home/centos/jode.sh ",
          
        ]
     }
}

 output "public_ip" {
        value = "${aws_instance.examples.public_ip}"

}
