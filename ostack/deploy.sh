#!/usr/bin/env bash
# Set color variable
CYAN='\033[1;36m'
NC='\033[0m' # No Color

set -e
# Provisions a virtual machine instance

# Local variables
export APP="${PORTAL_APP_REPO_FOLDER}"
echo "export APP=${APP}"

export TF_VAR_deployment_path="${PORTAL_DEPLOYMENTS_ROOT}/${PORTAL_DEPLOYMENT_REFERENCE}"
echo "export TF_VAR_deployment_path=${TF_VAR_deployment_path}"

export DPL="${PORTAL_DEPLOYMENTS_ROOT}/${PORTAL_DEPLOYMENT_REFERENCE}/"
echo "export DPL=${DPL}"

export PRIV_KEY_PATH="${DPL}${PORTAL_DEPLOYMENT_REFERENCE}"
echo "export PRIV_KEY_PATH=${PRIV_KEY_PATH}"

# Export input variables in the bash environment
export TF_VAR_name="$(awk -v var="${PORTAL_DEPLOYMENT_REFERENCE}" 'BEGIN {print tolower(var)}')"
echo "export TF_VAR_name=${TF_VAR_name}"

export KEY_PATH="${DPL}${PORTAL_DEPLOYMENT_REFERENCE}.pub"
echo "export KEY_PATH=${KEY_PATH}"

export TF_VAR_key_path="${KEY_PATH}"
echo "export TF_VAR_key_path=${TF_VAR_key_path}"

export TF_STATE=${DPL}'terraform.tfstate'
echo "export TF_STATE=${TF_STATE}"

# Launch provisioning of the VM
echo -e "\n\t${CYAN}Terraform apply${NC}\n"
terraform apply --state=${DPL}'terraform.tfstate' ${APP}'/ostack/terraform'

# Extract the internal IP of the Master instance
export k8s_master_private_ip="$(terraform output -state=${DPL}'terraform.tfstate' k8s_master_private_ip)"

# Install Ansible requirements with ansible galaxy
echo -e "\n\t${CYAN}Install Ansible requirements with ansible galaxy${NC}\n"
cd ostack/ansible || exit
ansible-galaxy install --force -r requirements.yml

# Set default value for Ansible variables if they are either empty or undefined
export ANSIBLE_REMOTE_USER="${TF_VAR_remote_user:-centos}"
echo "export ANSIBLE_REMOTE_USER=${ANSIBLE_REMOTE_USER}"

# Launch Ansible playbook
echo -e "\n\t${CYAN}Launch Ansible playbook${NC}\n"
ansible-playbook -e deployment_path=${TF_VAR_deployment_path} -e ansible_ssh_user=${ANSIBLE_REMOTE_USER} playbook.yml
