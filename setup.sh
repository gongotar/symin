#   Copyright 2022 Masoud Gholami
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

#!/bin/bash

# default values

symin_package_path=$HOME/.apps/packages
symin_install_path=$HOME/.apps/installs
symin_export_root=$HOME/.apps/root
symin_cores=`cat /proc/cpuinfo | grep processor | wc -l`
installer=symin

usage() {                                 # Function: Print a help message.
    echo "Usage: source $0 [ -p package_path ] [ -r export_root ] [ -i install_path ] [ -j cores ] [ -s installer_path ]" 1>&2 
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
        p) symin_package_path=${OPTARG};;
        r) symin_export_root=${OPTARG};;
        i) symin_install_path=${OPTARG};;
        j) symin_cores=${OPTARG};;
        s) installer=${OPTARG};;
        h) usage; exit 0;;
    esac
done

if [[ $symin_package_path != /* || $symin_install_path != /* || $symin_export_root != /* ]]; then
    exit_abnormal "Please provide the absolute paths."    
fi

mkdir -p $symin_package_path $symin_install_path $symin_export_root/usr/bin
status=$?
if test ! $status -eq 0; then
    exit_abnormal "Could not create the necessary directories. please check the permissions."
fi

symin_package_path_export="export symin_package_path=$symin_package_path"
symin_install_path_export="export symin_install_path=$symin_install_path"
symin_export_root_export="export symin_export_root=$symin_export_root"
symin_cores_export="export symin_cores=$symin_cores"

path_export="export PATH=$symin_export_root/usr/bin:$symin_export_root/usr/sbin:$symin_export_root/usr/local/bin:\$PATH"
lib_export="export LD_LIBRARY_PATH=$symin_export_root/usr/lib:$symin_export_root/usr/lib64:\$LD_LIBRARY_PATH"
c_include_export="export C_INCLUDE_PATH=$symin_export_root/usr/include:$symin_export_root/usr/local/include:\$C_INCLUDE_PATH"
cpp_include_export="export CPLUS_INCLUDE_PATH=$symin_export_root/usr/include:$symin_export_root/usr/local/include:\$CPLUS_INCLUDE_PATH"
cpath_export="export CPATH=$symin_export_root/usr/include:$symin_export_root/usr/local/include:\$CPATH"
pkgconfig_export="export PKG_CONFIG_PATH=$symin_export_root/usr/lib/pkgconfig:$symin_export_root/usr/lib64/pkgconfig:\${PKG_CONFIG_PATH}"

if [ ! -f $HOME/.bashrc ]; then
    touch $HOME/.bashrc
fi

sed -i "s|^\s*export symin_package_path=.*||g" $HOME/.bashrc
sed -i "s|^\s*export symin_install_path=.*||g" $HOME/.bashrc
sed -i "s|^\s*export symin_export_root=.*||g" $HOME/.bashrc
sed -i "s|^\s*export symin_cores=.*||g" $HOME/.bashrc

if ! grep -q "$symin_package_path_export" $HOME/.bashrc; then
    echo $symin_package_path_export >> $HOME/.bashrc
fi
if ! grep -q "$symin_install_path_export" $HOME/.bashrc; then
    echo $symin_install_path_export >> $HOME/.bashrc
fi
if ! grep -q "$symin_export_root_export" $HOME/.bashrc; then
    echo $symin_export_root_export >> $HOME/.bashrc
fi
if ! grep -q "$symin_cores_export" $HOME/.bashrc; then
    echo $symin_cores_export >> $HOME/.bashrc
fi

if ! grep -q "$path_export" $HOME/.bashrc; then
    echo $path_export >> $HOME/.bashrc
fi
if ! grep -q "$lib_export" $HOME/.bashrc; then
    echo $lib_export >> $HOME/.bashrc
fi
if ! grep -q "$c_include_export" $HOME/.bashrc; then
    echo $c_include_export >> $HOME/.bashrc
fi
if ! grep -q "$cpp_include_export" $HOME/.bashrc; then
    echo $cpp_include_export >> $HOME/.bashrc
fi
if ! grep -q "$cpath_export" $HOME/.bashrc; then
    echo $cpath_export >> $HOME/.bashrc
fi
if ! grep -q "$pkgconfig_export" $HOME/.bashrc; then
    echo $pkgconfig_export >> $HOME/.bashrc
fi

installer_new_path=$symin_export_root/usr/bin/symin

cp $installer $installer_new_path

#sed -i "s|^\s*symin_package_path=.*|symin_package_path=$symin_package_path|g" $installer_new_path
#sed -i "s|^\s*symin_install_path=.*|symin_install_path=$symin_install_path|g" $installer_new_path
#sed -i "s|^\s*symin_export_root=.*|symin_export_root=$symin_export_root|g" $installer_new_path
#sed -i "s|^\s*symin_cores=.*|symin_cores=$symin_cores|g" $installer_new_path

source $HOME/.bashrc
