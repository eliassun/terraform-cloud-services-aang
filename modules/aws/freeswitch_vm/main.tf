#****************************************************************************
# main.tf
# Terraform script to freeswitch vm
# Author: Elias Sun (eliassun@gmail.com)
#****************************************************************************

resource "aws_network_interface" "service_nic" {
    count           = var.instance_count
    subnet_id       = try(var.subnet_id[count.index], var.subnet_id[0])
    security_groups = var.sg
    tags = merge(var.tags, {
        Name = "${var.prefix}-fs-nic-${count.index+1}-${var.tag}"
    })
}

# Assign an elastic IP to the network interface created

resource "aws_eip" "service_eip" {
    count                     = var.instance_count
    vpc                       = true
    network_interface         = aws_network_interface.service_nic[count.index].id
    associate_with_private_ip = aws_instance.freeswitch[count.index].private_ip
    tags = merge(var.tags, {
        Name = "${var.prefix}-fs-nic-${count.index+1}-${var.tag}"
    })
    depends_on = [
        aws_instance.freeswitch,
        var.igw
    ]
}

data "http" "install" {
  url = "https://raw.githubusercontent.com/eliassun/eliassun.github.io/main/services/freeswitch/install_001.sh"
  request_headers = {
    Accept = "text/plain"
  }
}

# Fetch the latest Ubuntu 20.04 AMI for the bastion host
data "aws_ami" "ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "local_file" "install" {
  content  = tostring(data.http.install.response_body)
  filename = "../fs_install.sh"
  depends_on = [data.http.install]
}

# Create an ubuntu ec2 and install apache2
resource "aws_instance" "freeswitch" {
    count             = var.instance_count
    ami               = data.aws_ami.ami.id
    instance_type     = var.type
    key_name          = var.key_name
    network_interface {
        device_index = count.index
        network_interface_id = aws_network_interface.service_nic[count.index].id
    }
    user_data = tostring(data.http.install.response_body)
    tags = merge(var.tags, { Name = "${var.prefix}-ser-eip-${count.index+1}-${var.tag}" })
    depends_on = [
      local_file.install
    ]
}
