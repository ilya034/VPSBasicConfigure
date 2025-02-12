#!/bin/bash

while getopts u: flag
do
    case "${flag}" in
        u) new_user_name=${OPTARG};;
        p) new_ssh_port=${OPTARG};;
    esac
done

apt update && apt upgrade -y
clear

echo add new user
useradd $new_user_name -m -G sudo -s /bin/bash
passwd $new_user_name
clear

echo install xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta -u $new_user_name
clear

echo configure xray logs
cd /var/log
touch xray/access.log xray/error.log
chmod 775 -R xray
chown nobody:nogroup -R xray
cd
clear

echo install nginx
sudo apt install curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx
apt update
apt install nginx -y
clear

echo install acme.sh
wget -O -  https://get.acme.sh | sh -s email="$new_user_name"k@gmail.com
clear

echo install vimrc
curl -sLO https://github.com/ilya034/VPSBasicConfigure/raw/master/.vimrc

echo configure key auth
mkdir /home/$new_user_name/.ssh
touch /home/$new_user_name/.ssh/authorized_keys
chown $new_user_name:$new_user_name -R /home/$new_user_name/.ssh
chmod 700 /home/$new_user_name/.ssh
chmod 600 /home/$new_user_name/.ssh/authorized_keys
