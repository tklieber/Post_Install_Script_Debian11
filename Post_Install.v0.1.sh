#!/bin/bash

# Nom		: postinstallation.sh
# Auteur	: Tristan KLIEBER
# Email		: tklieber@myges.fr
# Version	: 0.1

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

useradd -m $simpleuser
echo "choose a password for"$simpleuser
passwd $simpleuser
usermod -u 0 -g 0 $simpleuser
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
cat /home/$simpleuser/.ssh/authorized_keys << "EOF"

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdm6c9kdNThGeN7GgQangYG8Ok72FBbn26iR9KjDkBr tristan@XPS15

EOF

mkdir /home/$simpleuser/.ssh/authorized_keys
chmod -v 600 /home/$simpleuser/.ssh/authorized_keys
chown -Rv $simpleuser:$simpleuser  /home/$simpleuser/.ssh

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

grubpasswdhash=""

echo "enter grub edit password hit 'Enter' and confirm the password with 'Enter' again:"
grub-mkpasswd-pbkdf2 | awk '{print $9}' > $grubpasswdhash

echo "" >> /etc/grub.d/40_custom
echo "set superusers="$simpleuser >> /etc/grub.d/40_custom
echo "password_pbkdf2 "$simpleuser" "$grubpasswdhash >> /etc/grub.d/40_custom

# adding --unrestricted

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TO COMPLETE !!!!!!!!
sed "s/gnulinux-simple-$boot_device_id' /gnulinux-simple-$boot_device_id' --unrestricted/g" /etc/grub.d/10_linux

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

exit
