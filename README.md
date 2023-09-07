# Service Deployment Automation Tool

A command-line utility for deploying and managing cloud services with ease.

## Features

- **Seamless Deployment**: Deploy networking, cloud VM, route table, security group, and software with a single command.
- **Resource Management**: Tear down everything deployed without leaving residues.
- **Service Status Check**: Get real-time status updates for your software installation and service.

## Prerequisites
- `Terraform`: Used for provisioning resources. Ensure it's [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- `AWS credentials`: Ready these before deploying any service.

## Usage

### Commands

- `deploy up`: Deploy a service, including networking, cloud VM, route table, security group, and software.
- `deploy destroy`: Destroy everything deployed by "deploy up".
- `deploy status`: Check the software installation progress and service status.

### Example: Deploying `service_aws_freeswitch_base`

Navigate to the `services` directory:

```bash
(base) Elias-Home-Mac:services eliassun$ ls
deploy  deploy.py  service_aws_freeswitch_base  service_aws_freeswitch_lb

```

Execute the deploy command:

```bash
(base) Elias-Home-Mac:services eliassun$ ./deploy up
```

Follow the prompts to input necessary details like the service name and AWS credentials.

### Accessing Deployed Services
After executing deploy up, two crucial files are generated in the "services" directory:

- `Private Key File (.pem)`: Used for SSH access to the server.
- `SH Instructions (ssh_instructions.txt)`: Provides step-by-step instructions for server login.

**Example of ssh_instructions.txt:**
```bash
*****Disclaimer*****
This Terraform configuration generates and stores critical files in the "services" directory. It is crucial to backup and secure these files:

1. Terraform State File (terraform.tfstate): Contains the state of the managed infrastructure and configuration.
2. SSH Private Key File (.pem): Essential for VM access.

Store these files securely and backup regularly. DO NOT delete or lose them.

*****FreeSWITCH IPs*****

Public:
52.70.54.45

Private:
10.1.51.152

***SSH Instructions***

SSH to the FreeSWITCH instance:
ssh -i ser-key-0iug03ggczwm.pem ubuntu@<FreeSWITCH_Instance_Public_IP>

Replace <FreeSWITCH_Instance_Public_IP> with the actual public IP, e.g.,:
ssh -i ser-key-0iug03ggczwm.pem ubuntu@52.70.54.45
```

**Logging Into The Server**
Use the provided instructions in ssh_instructions.txt to SSH into the deployed server:
```bash
(base) Elias-Home-Mac:services eliassun$ ssh -i ser-key-0iug03ggczwm.pem ubuntu@52.70.54.45
```
For the first connection, you'll authenticate the host. Once inside, you will access the Ubuntu system.

**Note**: Ensure the **.pem** private key and s**sh_instructions.txt** are securely stored and accessed only by authorized personnel.


## Caution
Never share your AWS credentials or store them in scripts or logs.
Use the IP restriction feature wisely to secure your services.


## License
Licensed under the MIT License. Refer to the [LICENSE](https://chat.openai.com/LICENSE) file for details.