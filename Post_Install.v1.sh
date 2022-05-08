#!/bin/bash

# Nom		: postinstallation.sh
# Auteur	: Tristan KLIEBER
# Email		: tklieber@myges.fr
# Version	: 1.3.1

# tester si on est en root
if [ "$USER" != "root" ]
then
	echo "vous n'êtes pas root"
	exit
fi

#test du nombre d'arguments

echo "++++++++++++++++++++++++++++++++++++++++++++++++"
echo ""
echo "début des mises à jours, installations des paquets nécessaire et désinstallation de ceux qui ne le sont pas"

# mettre à jour
apt update -y
apt upgrade -y

# Suppression des packages inutiles
apt-get purge  bluez bluetooth wpasupplicant wireless* telnet -y
apt-get autoremove -y

# Synchronisation avec une horloge atomique
timedatectl set-ntp off
timedatectl set-ntp on

# Installation les packages vraiment utiles
apt-get install vim sudo rsync mlocate net-tools lynx tree pigz pixz \
                git psmisc htop dstat iotop hdparm curl htop iotop \
                inxi rsync screen nmon bmon dstat \
                wget lynx net-tools mlocate tree \
                parted gdisk gddrescue pigz -y

killall dhclient
killall wpa_supplicant

echo ""
echo "Done !"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "changement de la conf du terminal"
echo ""

# Changement de bashrc pour root
cat > /root/.bashrc  << "EOF"

export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -rtl'
alias l='ls $LS_OPTIONS -lA'
alias ip='ip -c'
#
# Some more alias to avoid making mistakes:
 alias rm='rm -iv --preserve-root'
 alias chmod='chmod -v --preserve-root'
 alias chown='chown -v --preserve-root'
 alias chgrp='chgrp -v --preserve-root'

 alias cp='cp -iv'
 alias mv='mv -iv'

new_line(){
        printf "\n> \$"
}
export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] - [\w]\[\033[01;34m\]\[\033[00m\] $(new_line) '

alias plantu="netstat -plantu"
alias df="df -hT --total -x devtpmfs -x tmpfs"
alias cd..="cd .."
alias vi=vim
alias sc="systemctl"

alias start="systemctl start "
alias restart="systemctl start "
alias stop="systemctl stop "
alias reload="systemctl reload "

alias ipt="iptables -L -n"
alias mount="mount -v"
alias umount="umount -flv"
alias rgrep="find . type f|xargs grep -win"

EOF

echo `cat /root/.bashrc` >> /home/$simpleuser/.bashrc

echo "Done !"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Ajout du user"
echo ""

simpleuser=nimda

useradd -g $simpleuser -s /bin/bash $simpleuser
echo "choose a password for"$simpleuser
passwd $simpleuser
usermod -u 0 -g 0 -o $simpleuser
mkdir /home/$simpleuser

cp ~/.bashrc  /home/$simpleuser
chown -v $simpleuser:$simpleuser /home/$simpleuser/.bashrc

echo ""
echo "Le nouveau user à les droits suivants :"
sudo -U $simpleuser  -l

echo ""
echo "Done !"
echo ""
echo "+++++++++++++++++++++++++++++++++++++"
echo "mise en place de l'authentification ssh par clé"
echo ""

# Authentification par clés SSH de l'hôte vers la VM
mkdir -v /home/$simpleuser/.ssh
chmod -v 700 /home/$simpleuser/.ssh

touch /home/$simpleuser/.ssh/authorized_keys
cat > /home/$simpleuser/.ssh/authorized_keys << "EOF"

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdm6c9kdNThGeN7GgQangYG8Ok72FBbn26iR9KjDkBr tristan@XPS15

EOF

mkdir /home/$simpleuser/.ssh/authorized_keys
chmod -v 600 /home/$simpleuser/.ssh/authorized_keys
chown -Rv $simpleuser:$simpleuser  /home/$simpleuser/.ssh

sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sed -i "s/\#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config
sed -i "s/\#PubkeyAuthentication/PubkeyAuthentication/g" /etc/ssh/sshd_config

chmod -v 640 /etc/ssh/sshd_config
chmod -v 640 /etc/ssh/ssh_config

echo ""
echo "+=+=+=+=+=+=+=+=+=+=+=+=+="
echo "Customing Vim"

if test -f "/etc/vim/.vimrc";
then
        sed "s/\" set incsearch/set incsearch/g" /etc/vim/.vimrc
        sed "s/\" set number/set number/g" /etc/vim/.vimrc
        sed "s/\" set ruler/set ruler/g" /etc/vim/.vimrc
        sed "s/\" set title/set title/g" /etc/vim/.vimrc
        sed "s/\" set hlsearch/set hlsearch/g" /etc/vim/.vimrc
        sed "s/\"set mouse=a/set mouse=a/g" /etc/vim/.vimrc
        sed "s/\"set ignorecase/set ignorecase/g" /etc/vim/.vimrc
        sed "s/\" set visualbell/set visualbell/g" /etc/vim/.vimrc
        sed "s/\"set noerrorbells/set noerrorbells/g" /etc/vim/.vimrc

elif test -f "/home/"$simpleuser"/.vimrc";
then
    
        sed "s/\" set incsearch/set incsearch/g" /home/$simpleuser/.vimrc
        sed "s/\" set number/set number/g" /home/$simpleuser/.vimrc
        sed "s/\" set ruler/set ruler/g" /home/$simpleuser/.vimrc
        sed "s/\" set title/set title/g" /home/$simpleuser/.vimrc
        sed "s/\" set hlsearch/set hlsearch/g" /home/$simpleuser/.vimrc
        sed "s/\"set mouse=a/set mouse=a/g" /home/$simpleuser/.vimrc
        sed "s/\"set ignorecase/set ignorecase/g" /home/$simpleuser/.vimrc
        sed "s/\" set visualbell/set visualbell/g" /home/$simpleuser/.vimrc
        sed "s/\"set noerrorbells/set noerrorbells/g" /home/$simpleuser/.vimrc

elif test -f "/root/.vimrc";
then
    
        sed "s/\" set incsearch/set incsearch/g" /root/.vimrc
        sed "s/\" set number/set number/g" /root/.vimrc
        sed "s/\" set ruler/set ruler/g" /root/.vimrc
        sed "s/\" set title/set title/g" /root/.vimrc
        sed "s/\" set hlsearch/set hlsearch/g" /root/.vimrc
        sed "s/\"set mouse=a/set mouse=a/g" /root/.vimrc
        sed "s/\"set ignorecase/set ignorecase/g" /root/.vimrc
        sed "s/\" set visualbell/set visualbell/g" /root/.vimrc
        sed "s/\"set noerrorbells/set noerrorbells/g" /root/.vimrc
fi

echo ""
echo "Done Customing Vim for principal users !"
echo "+++++++++++++++"
echo "Installing Cheat"
echo ""


wget https://github.com/cheat/cheat/releases/download/4.2.3/cheat-linux-amd64.gz -P /home/$simpleuser
gunzip /home/$simpleuser/cheat-linux-amd64.gz
chmod +x /home/$simpleuser/cheat-linux-amd64
mv /home/$simpleuser/cheat-linux-amd64   /usr/local/bin/cheat

mkdir -p /home/$simpleuser/.config/cheat
mkdir  -vp /home/$simpleuser/.config/cheat/cheatsheets/community
mkdir -vp /home/$simpleuser/.config/cheat/cheatsheets/personal
chown -Rv $simpleuser:$simpleuser /home/$simpleuser/.config/cheat

cheat --init  > /home/$simpleuser/.config/cheat/conf.yml
sed -i '/path/ s;/root;~;' /home/$simpleuser/.config/cheat/conf.yml
git clone https://github.com/cheat/cheatsheets /home/$simpleuser/.config/cheat/cheatsheets/community

echo ""
echo "Done !"
echo "++++++++++++++++++++++++"
echo "Protecting the grub with a password"
echo ""


echo "enter grub edit password hit 'Enter' and confirm the password with 'Enter' again:"
grub-mkpasswd-pbkdf2 | awk '{print $9}' > $grubpasswdhash

echo "" >> /etc/grub.d/40_custom
echo "set superusers="$simpleuser >> /etc/grub.d/40_custom
echo "password_pbkdf2 "$simpleuser" "$grubpasswdhash >> /etc/grub.d/40_custom

# adding --unrestricted

sed -i "s/gnulinux-simple-$boot_device_id' /gnulinux-simple-$boot_device_id' --unrestricted/g" /etc/grub.d/10_linux

echo ""
echo ""
echo "++++++++++++"
echo ""
echo "=+=+=+=+=+=+ Backuping v0 files =+=+=+=+=+=+=+=+=+"
echo ""
echo "Saving luks header"
echo ""

mkdir -v -p /root/backup/v0/
cryptsetup luksHeaderBackup /dev/sda3 --header-backup-file /root/backup/v0/sda3.header.LUKS.cfg
pigz -p4 -k -9 /root/backup/v0/sda3.header.LUKS.cfg

echo ""
echo "Done !"
echo "+++++++++++++++"
echo "backup volume descriptor"

vgcfgbackup -f /root/backup/v0/sda.VGCFG.backup
pigz -p4 -k -9 /root/backup/v0/sda.VGCFG.backup

echo ""
echo "Done !"
echo "+++++++++++++++"
echo "backup boot and efi boot"

ddrescue /dev/sda1 /root/backup/v0/sda1.BOOT.ddr
ddrescue /dev/sda2 /root/backup/v0/sda2.BOOTefi.ddr
ddrescue /dev/VGCRYPT/lv_root /root/backup/v0/sda3.VGCRYPT.lv_root.ddr
ddrescue /dev/VGCRYPT/lv_var /root/backup/v0/sda3.VGCRYPT.lv_var.ddr
pigz -p4 -k -9 /root/backup/v0/sda1.BOOT.ddr
pigz -p4 -k -9 /root/backup/v0/sda2.BOOTefi.ddr
pigz -p4 -k -9 /root/backup/v0/sda3.VGCRYPT.lv_root.ddr
pigz -p4 -k -9 /root/backup/v0/sda3.VGCRYPT.lv_var.ddr

echo "Done !"
echo ""
echo "All Backups are in /root/backup"
echo ""
echo "++++++++++++++"
echo "Installing MariaDB"

apt install mariadb-server

echo ""
echo "++++++++++++++"
echo ""
echo "Configuring/securing MariaDB"
mysql_secure_installation <<EOF

y
nimda
nimda
y
y
y
y
EOF

mysql -u root -p <<EOF
nimda
nimda
CREATE DATABASE dolibarr;
CREATE USER 'nimda'@'localhost' IDENTIFIED BY 'nimda';
GRANT ALL PRIVILEGES ON dolibarr.* TO 'nimda'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

#Installation NGINX

echo ""
echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
echo "Installing nginx ..."

apt  install    nginx -y
apt  install    php-fpm php-mbstring php-tokenizer php-gd php-xml php-curl php-mysql \
		php-zip curl gnupg2 ca-certificates lsb-release nginx -y

echo ""
echo "Restarting GNINX"
echo ""
service nginx start

apt install php-fpm \
php-common php-curl php-intl \
php-mbstring php-json php-xmlrpc \
php-soap php-mysql php-gd \
php-xml php-cli php-zip;



#Installation Dolibarr
echo ""
echo "=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+"
echo "Installing Dolibarr ..."
echo ""
wget -O /tmp/dolibarr-15.0.1-4_all.deb https://sourceforge.net/projects/dolibarr/files/Dolibarr%20installer%20for%20Debian-Ubuntu%20%28DoliDeb%29/15.0.1/dolibarr_15.0.1-4_all.deb/download
dpkg -i /tmp/dolibarr_15.0.1-4_all.deb

cp -r /usr/share/dolibarr/ /var/www/html/dolibarr/

chown -R www-data:www-data /var/www/html/dolibarr/
find /var/www/html/dolibarr -type f -exec chmod 644 {} \;
find /var/www/html/dolibarr -type d -exec chmod 755 {} \;
mkdir /var/www/html/dolibarr/documents
chown -R www-data:www-data /var/www/html/dolibarr/documents
chmod 644 /var/www/html/dolibarr/documents


cat > /etc/nginx/sites-available/dolibarr.conf << "EOF"
server {
    listen 443 ssl;
    listen [::]:443;
    root /var/www/html/dolibarr/htdocs;
    index  index.php index.html index.htm;
    server_name  erp.charles.local www.erp.charles.local;

    ssl_certificate	/etc/nginx/certificate/erp.charles.local.crt;
    ssl_certificate_key	/etc/nginx/certificate/erp.charles.local.key;
    ssl_protocols	TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers		HIGH:!aNULL:!MD5;

    client_max_body_size 100M;

    location ~ ^/api/(?!(index\.php))(.*) {
      try_files $uri /api/index.php/$2?$query_string;
    }

    location ~ [^/]\.php(/|$) {
        include fastcgi_params;
        if (!-f $document_root$fastcgi_script_name) {
            return 404;
        }
        fastcgi_pass           unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
     }
}
EOF

ln -s /etc/nginx/sites-available/dolibarr.conf /etc/nginx/sites-enabled/

echo ""
echo "Restarting NGINX"
echo ""

service nginx restart

touch /var/www/html/dolibarr/documents/install.lock
chmod 0440 /var/www/html/dolibarr/documents/install.lock

echo ""
echo "Edit the file /etc/php/7.4/fpm/php.ini"
echo ""
echo "file_uploads = On"
echo "allow_url_fopen = On"
echo "memory_limit = 512M"
echo "upload_max_filesize = 100M"
echo "max_execution_time = 360"
echo "date.timezone = Europe/Paris"
echo "--> service php7.3-fpm restart"


echo ""
echo "Done installing !"


exit
