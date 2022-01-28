#!/bin/bash

# default values

package_path=$HOME/.apps/packages
install_path=$HOME/.apps/installs
export_root=$HOME/.apps/root
cores=`cat /proc/cpuinfo | grep processor | wc -l`
installer=syminst.sh

usage() {                                 # Function: Print a help message.
    echo "Usage: $0 [ -p package_path ] [ -r export_root ] [ -i install_path ] [ -j cores ] [ -s installer_path ]" 1>&2 
}
exit_abnormal() {                         # Function: Exit with error.
    echo "Error:" 1>&2
    echo $1 1>&2
    usage
    exit 1
}

# get terminal inputs

while getopts ":p:r:i:j:h" flag
do
    case "${flag}" in
        p) package_path=${OPTARG};;
        r) export_root=${OPTARG};;
        i) install_path=${OPTARG};;
        j) cores=${OPTARG};;
        s) installer=${OPTARG};;
        h) usage; exit 0;;
    esac
done

if [[ $package_path != /* || $install_path != /* || $export_root != /* ]]; then
    exit_abnormal "Please provide the absolute paths."    
fi

mkdir -p $package_path $install_path $export_root
status=$?
if test ! $status -eq 0; then
    exit_abnormal "Could not create the necessary directories. please check the permissions."
fi

path_export="export PATH=\$PATH:$export_root/usr/bin:$export_root/usr/sbin"
lib_export="export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$export_root/usr/lib:$export_root/usr/lib64"

if ! grep -q "$path_export" $HOME/.bashrc; then
    echo $path_export >> $HOME/.bashrc
fi
if ! grep -q "$lib_export" $HOME/.bashrc; then
    echo $lib_export >> $HOME/.bashrc
fi


sed -i "s|^\s*package_path=.*|package_path=$package_path|g" $installer
sed -i "s|^\s*install_path=.*|install_path=$install_path|g" $installer
sed -i "s|^\s*export_root=.*|export_root=$export_root|g" $installer
sed -i "s|^\s*cores=.*|cores=$cores|g" $installer

source $HOME/.bashrc
