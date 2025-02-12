#!/bin/bash

while getopts u: flag
do
    case "${flag}" in
        u) newusername=${OPTARG};;
    esac
done

apt update && apt upgrade -y

echo add new user
useradd $newusername -m -G sudo -s /bin/bash
passwd $newusername

echo install xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta -u &newusername

echo configure xray logs
cd /var/log
touch xray/access.log xray/error.log
chmod 775 -R xray
chown nobody:nogroup -R xray
cd

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
apt install nginx

echo install acme.sh
wget -O -  https://get.acme.sh | sh -s email="$newusername"k@gmail.com

echo install vimrc
curl -sLO https://github.com/ilya034/VPSBasicConfigure/raw/master/.vimrc

echo configure key auth
mkdir /home/$newusername/.ssh
touch /home/$newusername/.ssh/authorized_keys
chown $newusername:$newusername -R /home/$newusername/.ssh
chmod 700 /home/$newusername/.ssh
chmod 600 /home/$newusername/.ssh/authorized_keys
