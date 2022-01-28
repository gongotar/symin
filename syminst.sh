#!/bin/bash

# default values

package_path=/home/bemghola/.apps/packages
install_path=/home/bemghola/.apps/installs
export_root=/home/bemghola/.apps/root
cores=4


ext="tar.gz"
uninstall="false"

# define functions

usage() {                                 # Function: Print a help message.
    echo "Usage: $0 [ -f filename ] [ -n name ] [ -e extension ] [ -l URL ] [ -u ] [ -p package_path ] [ -r export_root ] [ -i install_path ] [ -j cores ]" 1>&2 
}

exit_abnormal() {                         # Function: Exit with error.
    echo "Error:" 1>&2
    echo $1 1>&2
    usage
    exit 1
}

# get terminal inputs

while getopts ":ul:f:e:p:r:i:j:h" flag
do
    case "${flag}" in
        u) uninstall="true";;
        l) url=${OPTARG};;
        n) name=${OPTARG};;
        f) filename=${OPTARG};;
        e) ext=${OPTARG};;
        p) package_path=${OPTARG};;
        r) export_root=${OPTARG};;
        i) install_path=${OPTARG};;
        j) cores=${OPTARG};;
        h) usage; exit 0;;
    esac
done

if [[ $package_path != /* || $install_path != /* || $export_root != /* ]]; then
    exit_abnormal "Please provide the absolute paths."    
fi
if [[ ! -d $package_path || ! -d $export_root || ! -d $install_path ]]; then
    exit_abnormal "Please run init_syminst.sh first to create the necessary directories."
fi

# infer the name, filename, and url from each other if required and possible

if [[ -z $name && -z $filename && ! -z $url ]]; then    # get filename from url
    filename=`echo $url | rev | cut -d '/' -f1 | rev`
fi
if [[ -z $name && ! -z $filename ]]; then   # get name from filename
    fext=${filename:${#filename}-${#ext}:${#filename}}
    case $fext in 
        tar.gz|tar.bz|tar.xz|$ext) 
            ext=$fext;;
        *) 
            exit_abnormal "Unknown extension $fext of file $filenamme. Try setting the file extension using the flag -e";;
    esac
    name=${filename:0:${#filename}-${#ext}-1}
elif [[ -z $filename && ! -z $name ]]; then     # get filename from name
    filename="$name"."$ext"
elif [[ -z $name && -z $filename ]]; then
    exit_abnormal "Empty name and filename!"
fi


# perform install / uninstall

if [ $uninstall == "false" ]; then

    pushd $package_path
    if [ ! -z "$url" ]; then
        wget $url
    fi

    if [ ! -f $filenamme]; then
        popd
        exit_abnormal "Could not find file $filename under $package_path"
    fi

    tar -xf $filename
    
    if [ ! -d $name ]; then
        popd
        exit_abnormal "Could not find directory $name under $package_path"
    fi

    pushd $name

    if [[ ! -f configure && -f autogen.sh ]]; then
        ./autogen.sh
        status=$?
        if test ! $status -eq 0; then
            popd
            popd
            exit_abnormal "Unsuccessful autogen.sh!"
        fi
    fi

    ./configure --prefix=$export_root/usr
    status=$?
    if test ! $status -eq 0; then
        popd
        popd
        exit_abnormal "Unsuccessful configure!"
    fi

    make -j$cores
    status=$?
    if test ! $status -eq 0; then
        popd
        popd
        exit_abnormal "Unsuccessful make!"
    fi

    mkdir $install_path/$name
    make DESTDIR=$install_path/$name install
    status=$?
    if test ! $status -eq 0; then
        popd
        popd
        exit_abnormal "Unsuccessful make install!"
    fi

    cp -srv $install_path/"$name"$export_root/usr $export_root
    popd
    rm -rf $name
    popd

    echo "Package $name is symlink-installed under: $export_root"
    echo "The regular installation files can be found under: $install_path/$name"

elif [ $uninstall == "true" ]; then

    find $export_root -lname "$install_path/$name*" -delete
    rm -rf $install_path/$name
#    pushd $package_path
#    find $package_path -name $filename -delete
#    popd
    echo "Package $name has been removed!"

fi

