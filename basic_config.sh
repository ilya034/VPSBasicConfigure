#!/bin/bash

set -e

NEW_USER_NAME=ilya034
PUBLIC_SSH_KEY=""
NEW_SSH_PORT=22

while getopts :u:k:p flag
do
    case "${flag}" in
        u) NEW_USER_NAME=${OPTARG};;
        k) PUBLIC_SSH_KEY=${OPTARG};;
        p) NEW_SSH_PORT=${OPTARG};; 
    esac
done

apt update && apt upgrade -y
apt install htop vim wget curl speedtest-cli gnupg2 ca-certificates lsb-release ubuntu-keyring -y

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list

echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | tee /etc/apt/preferences.d/99nginx

apt update
apt install nginx -y

useradd -M xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta -u xray

useradd ${NEW_USER_NAME} -m -G sudo -s /bin/bash

curl -sLO https://github.com/ilya034/VPSBasicConfigure/raw/master/.vimrc
cp .vimrc /home/${NEW_USER_NAME}/

mkdir -p /home/${NEW_USER_NAME}/.ssh
echo "${PUBLIC_SSH_KEY}" > /home/${NEW_USER_NAME}/.ssh/authorized_keys
chown -R ${NEW_USER_NAME}:${NEW_USER_NAME} /home/${NEW_USER_NAME}/.ssh 
chmod 700 /home/${NEW_USER_NAME}/.ssh
chmod 600 /home/${NEW_USER_NAME}/.ssh/authorized_keys

curl -sLo /etc/ssh/sshd_config.d/updated.conf https://github.com/ilya034/VPSBasicConfigure/raw/master/sshd.conf
echo "Port ${NEW_SSH_PORT}" >> /etc/ssh/sshd_config.d/updated.conf
echo "Include /etc/ssh/sshd_config.d/updated.conf" >> /etc/ssh/sshd_config
