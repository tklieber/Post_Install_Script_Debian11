#!/bin/bash

# Auteur	: Tristan Klieber
# Date		: 07-05-2022
# Description	: Script de backup des disques

declare -a backupFiles=()
TodaysDate=$(date +%Y-%m-%d)

# Test if we are root
if [ "$USER" != "root" ]
then
        echo "launch the script as root"
        exit
fi


if ! [ test -f "/data/backup" ];
then
	mkdir -r /data/backup/
fi


# Saving Luks Headers

echo "Backuping LUKS Headers.."
echo""
cryptsetup luksHeaderBackup /dev/nvme0n1p3 --header-backup-file /data/backup/$TodaysDate.nvme0n1p3.header.luks.cfg

pigz -p8 -k -9 /data/backup/$TodaysDate.nvme0n1p3.header.luks.cfg

backupFiles+=("/data/backup/$TodaysDate.nvme0n1p3.header.luks.cfg")

# Backup volume Descriptor

echo ""
echo "Backuping volume descriptor..."
vgcfgbackup -f /data/backup/$TodaysDate.VGCFG.backup
pigz -p8 -k -9 /data/backup/$TodaysDate.VGCFG.backup

backupFiles+=("/data/backup/$TodaysDate.VGCFG.backup")

# Backup Boot and Boot EFI partitions and LVMCrypt

echo ""
echo "backuping BOOT nvme0n1p1..."
ddrescue /dev/nvme0n1p1 /data/backup/$TodaysDate.nvme0n1p1.BOOT.ddr
pigz -p4 -k -9 /data/backup/$TodaysDate.nvme0n1p1.BOOT.ddr
backupFiles+=("/data/backup/$TodaysDate.nvme0n1p1.BOOT.ddr")

echo ""
echo "backuping BOOT EFI nvme0n1p2..."
ddrescue /dev/nvme0n1p2 /data/backup/$TodaysDate.nvme0n1p2.BOOTefi.ddr
pigz -p4 -k -9 /data/backup/$TodaysDate.nvme0n1p2.BOOTefi.ddr
backupFiles+=("/data/backup/$TodaysDate.nvme0n1p2.BOOTefi.ddr")

echo ""
echo "Backuping vgkubuntu/root..."
ddrescue /dev/vgkubuntu/root /data/backup/$TodaysDate.root.vgkubuntu.ddr
pigz -p4 -k -9 /data/backup/$TodaysDate.root.vgkubuntu.ddr
backupFiles+=("/data/backup/$TodaysDate.root.vgkubuntu.ddr")

echo ""
echo "Backuping vgkubuntu/swap_1..."
ddrescue /dev/vgkubuntu/swap_1 /data/backup/$TodaysDate.swap_1.vgkubuntu.ddr
pigz -p4 -k -9 /data/backup/$TodaysDate.swap_1.vgkubuntu.ddr
backupFiles+=("/data/backup/$TodaysDate.swap_1.vgkubuntu.ddr")

echo ""
echo "Deleting uncompressed versions of the files"
echo ""
# Supprime les fichiers non compressés
length=${#backupFiles[@]}
for file in ${backupFiles[*]};
do
	if test -f $file;
	then
		rm -vf $file
	fi
done


# Backuping SQL database
# Replace with SQL DB Name
mysqldump --user=admin_backup --password=nimda --lock-tables --all-databases > /data/backup/dbs.sql

echo ""
echo "Done !"
echo "All backups are in /data/backup/"
