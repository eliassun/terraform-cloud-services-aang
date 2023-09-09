#!/usr/bin/env python
"""
deploy.py

Author: Elias Sun (eliassun@gmail.com)

deploy up:  deploy a service including networking, cloud VM, route table, security group and software
deploy destroy: destroy everything deployed by "deploy up"
deploy status: check the software installation progress and service status

"""

import argparse
import json
import os
import sys
import ipaddress
import subprocess

TERRAFORM_VAR_FILE = './.tf_env'
TERRAFORM_VAR_BIN = './bin/terraform'
CMD_TERRAFORM_UP = 'up'
CMD_TERRAFORM_DESTROY = 'destroy'
CMD_TERRAFORM_STATUS = 'status'
CMD_TERRAFORM_REFRESH = 'refresh'
RESULT_GO_TO_PYTHON = 'result_req_do_something'

APP_INSTALL_LOG = './.install_progress'


services = ['service_aws_freeswitch_base', 'service_aws_freeswitch_asg', 'service_aws_fs_asg_alb']
regions=["us-east-1","us-east-2","us-gov-east-1","us-gov-west-1","us-west-1","us-west-2"
         "af-south-1","ap-east-1","ap-northeast-1", "ap-northeast-2","ap-northeast-3","ap-south-1",
         "ap-southeast-1","ap-southeast-2","ca-central-1","cn-north-1", "cn-northwest-1","eu-central-1",
         "eu-north-1","eu-south-1","eu-west-1","eu-west-2","eu-west-3","me-south-1","sa-east-1"]

def input_none_empty(prompt):
    val = ''
    while not val:
        try:
            val = input(prompt)
        except Exception:
            pass
    return val

def input_empty_allow(prompt):
    val = ''
    try:
        val = input(prompt)
    except Exception:
        pass
    return val

def deploy(tf_env):
    try:
        service = tf_env.get('service')
        cmd = f'cd {service}; terraform init; terraform apply'
        ret = subprocess.run(cmd, shell=True, env=tf_env, stderr = subprocess.STDOUT)
    except Exception as err:
        print(f'Failed to deploy. Error: {err}')
        return False
    if ret.returncode:
        print('Failed to deploy.')
        print(ret.stderr)
    return True

def refresh(tf_env):
    try:
        service = tf_env.get('service')
        cmd = f'cd {service}; terraform refresh'
        ret = subprocess.run(cmd, shell=True, env=tf_env, stderr = subprocess.STDOUT)
    except Exception as err:
        print(f'Failed to refresh outputs. Error: {err}')
        return False
    if ret.returncode:
        print('Failed to refresh outputs.')
        print(ret.stderr)
    return True

def env():
    env = dict(os.environ)
    with open(TERRAFORM_VAR_FILE, 'r+') as fvar:
        content = fvar.readlines()
    for line in content:
        key, val = line.split('=')
        env[key.strip()] = val.strip()
    return env

def deploy_up():
    if os.path.isfile(TERRAFORM_VAR_FILE):
        tf_vars = env()
        service = tf_vars.get('service')
        ret = input_none_empty(f'Find an existing \"{service}\" deployed. Are you sure to refresh the deployment again?(yes/no):')
        if ret == 'yes':
            deploy(tf_vars)
        sys.exit(0)
    tf_vars = {}
    service = input_none_empty('Enter Service Name:')
    if service not in services:
        print(f'Wrong service name: {service}')
        return False
    tf_vars['service'] = service

    tf_vars['TF_VAR_aws_access_key_id'] = input_none_empty('Enter AWS Access Key ID:')
    tf_vars['AWS_ACCESS_KEY_ID'] = tf_vars['TF_VAR_aws_access_key_id']

    tf_vars['TF_VAR_aws_secret_access_key'] = input_none_empty('Enter AWS Secret Access Key:')
    tf_vars['AWS_SECRET_ACCESS_KEY'] = tf_vars['TF_VAR_aws_secret_access_key']

    tf_vars['TF_VAR_aws_session_token']  = input_empty_allow('Enter AWS Session Token (Optional):')
    if tf_vars['TF_VAR_aws_session_token']:
        tf_vars['AWS_SESSION_TOKEN'] = tf_vars['TF_VAR_aws_session_token']

    aws_region = input_none_empty('Enter AWS Region (e.g. us-east-1):')
    while aws_region not in regions:
        print(f'Wrong AWS region: {aws_region}. Allowed regions:{regions}')
        aws_region = input_none_empty('Enter AWS Region (e.g. us-east-1):')

    tf_vars['TF_VAR_region'] = aws_region
    tf_vars['AWS_DEFAULT_REGION'] = aws_region

    outs = subprocess.run(["curl", "ifconfig.me"], capture_output=True)
    if not outs.stdout.decode('utf-8'):
        sys.exit(outs.stderr.decode('utf-8'))
    local_public_ip = str(outs.stdout.decode('utf-8'))
    lock_local_ssh = input_none_empty(f'Current Public IP is {local_public_ip}. '
                                      f'Only allow this IP to ssh this service? [yes/no]')
    while lock_local_ssh not in ['yes', 'no']:
        lock_local_ssh = input_none_empty(f'Current Public IP is {local_public_ip}. '
                                          f'Only allow this IP to ssh this service? [yes/no]')
    if lock_local_ssh == 'yes':
        tf_vars['TF_VAR_bastion_allow_ssh'] = json.dumps([f'{local_public_ip}/32'])
    else:
        allow_ssh = input_empty_allow('Enter CIDR allowed to ssh this service (default=0.0.0.0/0):')
        if not allow_ssh:
            allow_ssh = '0.0.0.0/0'
        is_correct_cidr = False
        while not is_correct_cidr:
            try:
                ipaddress.ip_network(allow_ssh)
                is_correct_cidr = True
            except ValueError:
                print(f'Invalid IP CIDR: {allow_ssh}')
                allow_ssh = input_empty_allow('Enter CIDR allowed to ssh this service (default=0.0.0.0/0):')

        tf_vars['TF_VAR_bastion_allow_ssh'] = json.dumps([allow_ssh])

    text = ''
    for key, val in tf_vars.items():
        text += f'{key}={val}\n'

    with open(TERRAFORM_VAR_FILE, 'w') as tf:
        tf.write(text)
    deploy(env())
    return False

def destroy(tf_env):
    try:
        service = tf_env.get('service')
        cmd = f'cd {service}; terraform destroy'
        ret = subprocess.run(cmd, shell=True, env=tf_env)
    except Exception as err:
        print(f'Failed to deploy. Error: {err}')
        return False
    if ret.returncode:
        print('Failed to destroy the service.')
        print(ret.stderr)
        return False
    try:
        service = tf_env.get('service')
        cmd = f'cd {service}; '
        cmd = cmd + (r'rm -rf terraform.tfstate; rm -rf .terraform; rm -rf .terraform.lock.hcl; rm -rf terraform.tfstate.backup; cd ..; now=$(date +"%Y-%m-%d-%H_%M_%S"); '
                     r'cp .tf_env .tf_env_${now}; echo ".tf_env_${now} is archived."; rm -rf .tf_env; rm -rf fs_install.sh; '
                     r'rm -rf .progress_log; rm -rf *.log; rm -rf freeswitch.status ')
        ret = subprocess.run(cmd, shell=True, env=tf_env)
    except Exception as err:
        print(err)
    if ret.returncode:
        print('Some errors when trying to destroy the deployment!')
        print(ret.stderr)
    return True

def deploy_destroy():
    if os.path.isfile(TERRAFORM_VAR_FILE):
        tf_vars = env()
        service = tf_vars.get('service')
        ret = input_none_empty(f'Find an existing \"{service}\" deployed. Are you sure to destroy this deployment?(yes/no):')
        if ret == 'yes':
            destroy(tf_vars)
        sys.exit(0)
    print('No existing service to destroy!')

def deploy_refresh():
    if os.path.isfile(TERRAFORM_VAR_FILE):
        refresh( env())
        sys.exit(0)
    print('No existing service to refresh!')

def deploy_status():
    if not os.path.isfile(APP_INSTALL_LOG):
        print('0% ...')
        return
    print('Checking App installation progress ...')
    cmd = f'chmod +x {APP_INSTALL_LOG}; ./{APP_INSTALL_LOG}'
    subprocess.run(cmd, shell=True)
    return ''


def get_parser():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers()

    parser_req_from_go = subparsers.add_parser(CMD_TERRAFORM_UP, help='Deploy service')
    parser_req_from_go.set_defaults(func=lambda o: deploy_up())

    parser_req_from_go = subparsers.add_parser(CMD_TERRAFORM_DESTROY, help='Destroy service')
    parser_req_from_go.set_defaults(func=lambda o: deploy_destroy())

    parser_req_from_go = subparsers.add_parser(CMD_TERRAFORM_STATUS, help='Show App install progress')
    parser_req_from_go.set_defaults(func=lambda o: deploy_status())

    parser_req_from_go = subparsers.add_parser(CMD_TERRAFORM_REFRESH, help='Fresh Outputs')
    parser_req_from_go.set_defaults(func=lambda o: deploy_refresh())

    return parser

def parse_args(args=None):
    reqs = get_parser().parse_args(args=args)
    return reqs

def main(reqs=None):
    return reqs.func(reqs)


if __name__ == '__main__':
    print(main(parse_args()))
    sys.exit(0)
