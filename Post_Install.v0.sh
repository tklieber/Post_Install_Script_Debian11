#!/bin/bash

# Nom		: postinstallation.sh
# Auteur	: Tristan KLIEBER
# Email		: tklieber@myges.fr
# Version	: v.0

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
cat > ~/.bashrc  << "EOF"

export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -rtl'
alias l='ls $LS_OPTIONS -lA'
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

alias notes='echo $(date +%A,\ %d\ %B\ \(%F_%R\)\ ) "$@" >>  ~/.notes'
alias cn="cat ~/.notes"
alias en="vim +$ ~/.notes"

EOF

# changement de bashrc pour le user initialement mis, ici "toto"
cat > /home/toto/.bashrc  << "EOF"

export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -rtl'
alias l='ls $LS_OPTIONS -lA'
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
alias df="df -hT --total -x devtmpfs -x tmpfs"
alias cd..="cd .."
alias vi=vim
alias sc="systemctl"

alias start="systemctl start "
alias restart="systemctl start "
alias stop="systemctl stop "
alias reload="systemctl reload "

alias mount="mount -v"
alias umount="umount -flv"


EOF

echo "Done !"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Ajout du user de base au sudoers"
echo ""

simpleuser=nimda

useradd -m $simpleuser
passwd $simpleuser
usermod -u 0 -g 0 $simpleuser
mkdir /home/$simpleuser

cp ~/.bashrc  /home/$simpleuser
chown -v $simpleuser:$simpleuser /home/$simpleuser/.bashrc

echo""
echo"Le nouveau user à les droits suivants :"
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


cat > /home/$simpleuser/.ssh/authorized_keys << "EOF"

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILdm6c9kdNThGeN7GgQangYG8Ok72FBbn26iR9KjDkBr tristan@XPS15

EOF

mkdir /home/$simpleuser/.ssh/authorized_keys
chmod -v 600 /home/$simpleuser/.ssh/authorized_keys
chown -Rv $simpleuser:$simpleuser  /home/$simpleuser/.ssh

chmod -v 640 /etc/ssh/sshd_config
chmod -v 640 /etc/ssh/ssh_config

echo""
echo"Done !"
echo"+++++++++++++++"
echo"Installing Cheat"
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
sed -i '/editor/ s;/vim;nano;' /home/$simpleuser/.config/cheat/conf.yml
git clone https://github.com/cheat/cheatsheets /home/$simpleuser/.config/cheat/cheatsheets/community

echo""
echo"Done !"
echo"++++++++++++++++++++++++"
echo"config de vim"

echo "0" > /etc/vim/vimrc
cat /etc/vim/vimrc << "EOF"
" All system-wide defaults are set in $VIMRUNTIME/debian.vim and sourced by
" the call to :runtime you can find below.  If you wish to change any of those
" settings, you should do it in this file (/etc/vim/vimrc), since debian.vim
" will be overwritten everytime an upgrade of the vim packages is performed.
" It is recommended to make changes after sourcing debian.vim since it alters
" the value of the 'compatible' option.

runtime! debian.vim

" Vim will load $VIMRUNTIME/defaults.vim if the user does not have a vimrc.
" This happens after /etc/vim/vimrc(.local) are loaded, so it will override
" any settings in these files.
" If you don't want that to happen, uncomment the below line to prevent
" defaults.vim from being loaded.
" let g:skip_defaults_vim = 1

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
"set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
"au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Uncomment the following to have Vim load indentation rules and plugins
" according to the detected filetype.
"filetype plugin indent on

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
"set showcmd		" Show (partial) command in status line.
"set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
"set autowrite		" Automatically save before commands like :next and :make
"set hidden		" Hide buffers when they are abandoned
"set mouse=a		" Enable mouse usage (all modes)
set nocompatible	" Annule la compatibilite avec l’ancetre Vi : totalement indispensable
set title		" Met a jour le titre de votre fenetre ou du terminal
set number		" Numéro de lignes
set ruler		" Afiche le numéro des lignes
set hlsearch		" Surligne les résultats de recherche

" On désactive les Beep
set visualbell
set noerrorbells

" Active le comportement ’habituel’ de la touche retour en arriere
set backspace=indent,eol,start

" Source a global configuration file if available
if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

EOF

echo""
echo"Done Custom vim !"
echo"++++++++++++++++++++++++"
echo"Protecting the grub with a password"
echo""

grub-mkpasswd-pbkdf2

echo""
echo"edit /etc/grub.d/40_custom with :"
echo"hash generated with the last cmd"
echo"add --unrestricted to line 'menuentry' in /etc/grub.d/10_linux"

echo""
echo""
echo"++++++++++++"
echo"Saving luks header"
echo""

mkdir -v /root/backup/
cryptsetup luksHeaderBackup /dev/sda3 --header-backup-file /root/backup/sda3.header.LUKS.cfg
pigz -p4 -k -9 /root/backup/sda3.header.LUKS.cfg

echo""
echo"Done !"
echo"+++++++++++++++"
echo"backup volume descriptor"

vgcfgbackup -f /root/backup/sda.VGCRYPT.backup
pigz -p4 -k -9 /root/backup/sda.VGCRYPT.backup

echo""
echo"Done !"
echo"+++++++++++++++"
echo"backup boot and efi boot"

ddrescue /dev/sda1 /root/backup/sda1.BOOT.ddr
ddrescue /dev/sda2 /root/backup/sda2.BOOTefi.ddr
ddrescue /dev/sda3 /root/backup/sda3.VGCRYPT.ddr
pigz -p4 -k -9 /root/backup/sda1.BOOT.ddr
pigz -p4 -k -9 /root/backup/sda2.BOOTefi.ddr
pigz -p4 -k -9 /root/backup/sda3.VGCRYPT.ddr

echo"Done !"
echo""
echo"All Backups are in /root/backup"
echo""
echo"++++++++++++++"

exit
