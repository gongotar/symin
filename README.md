# Symin
Symlink Installer - A lightweight script to install / remove packages using symlink-style package management

**Symin** is a leightweight package manager for installing packages from source code in Linux. The packages can be installed and removed locally under the *home* directory with a single command. 

## Usage
First, execute `source setup.sh` to create the initial directories and configure the library and binary paths. 
For installing/uninstalling a package, `symin` can be invoked as follows:
```sh
symin -l https://ftp.gnu.org/gnu/bc/bc-1.07.tar.gz     # install from the URL (archive will be downloaded)
symin -f bc-1.07.tar.gz                                # install from the archive file (archive file should be available)
symin -n bc-1.07                                       # install by the name (archive file should be available)
```

Notice that this script only supports installations that follow the common behavior of `./configure & make & make install` with the optional configure command. If necessary, `autogen.sh` is performed before `./configure`.


## Package Management

Packages are maintained in three directories:
- **package_path:** contains all the archive files of the packages in case they are needed in the future.
- **export_root:** contains the directories that are exported in the `$PATH` and `$LD_LIBRARY_PATH` environment variables (in _.bashrc_).
  - The directories `<export_root>/usr/bin` and `<export_root>/usr/sbin` are exported to `$PATH`. 
  - The directories `<export_root>/usr/lib` and `<export_root>/usr/lib64` are exported to `$LD_LIBRARY_PATH`. 
- **install_path:** the packages are installed here in separate directories for each package. Hence, they can be distinguished easily by their directories. Though, these directories are not exported to the `$PATH` and `$LD_LIBRARY_PATH` environment variables.

`symin` performs the installation of a package `package_name`in _fakeroot_: 
1. It configures the package to be installed under the `export_root/usr/` directory. 
    - The package _thinks_ it is going to be installed under `export_root/usr/`.
3. `symin` redirects the installation (`make install`) to install the files under the `install_path/package_name` directory instead. 
    - As a result, the files are actually placed under `install_path/package_name`.
4. Then, `symin` recursively creates symbolic links under `export_root/usr` pointing to all files that are installed under `install_path/package_name`. 
    - As a result, the installed files are visible in the exported paths to the `$PATH` and `$LD_LIBRARY_PATH` environment variables without actually being installed there. 
    - The files find each other under `export_root/usr` as they expect.
    - The packages are keeped separated in different directories. 

`symin` uninstalls a package `package_name` by removing the files in the `export_root/usr` that point to the `install_path/package_name`, and then removing the `install_path/package_name` itself.


## setup.sh

`Usage: setup.sh [ -p package_path ] [ -r export_root ] [ -i install_path ] [ -j cores ] [ -s installer_path ]`

All flags are optional and `setup.sh` can be invoked without defining any flags (default values are enough). Following flags can be adjusted according to more specific usages:
- `-p <package_path>`: defines the package path to keep the archive files.
- `-r <export_root>`: the directory that is exported to the `$PATH` and `$LD_LIBRARY_PATH` environment variables.
- `-i <install_path>`: the directory containing the installed packages in separate directories each.
- `-j <cores>`: the number of cores for `make`. This is automatically detected if not specified.
- `-s <installer_path>`: the path to the `symin` script.

## symin

`Usage: symin [ -f filename ] [ -n name ] [ -e extension ] [ -l URL ] [ -c configure_options ] [ -u ] [ -p package_path ] [ -r export_root ] [ -i install_path ] [ -j cores ]`

All flags are optional, though, at the end, `symin` should be able to infer the filename of the archive.
- `-f <filename>`: archive file name. If not specified, it is either defined as _name_+._extension_ (`-n <name>`, `-e <extension>`), or by the URL (`-l <URL>`).
- `-n <name>`: the _name_ of the unpacked archive. If the _name_ and _filename_ follow the usuall pattern of _filename=name.extension_, specifying one of _name_ or _filename_ suffices.
- `-e <extension>`: the extension of the archive file. the default is `tar.gz`. This is rarely needed when _filename_ cannot be inferred from other information.
- `-l <URL>`: the URL to download the archive file. If the URL contains the archive name (_filename_) at its end, `symin` extracts the _filename_ if `-f` is not specified.
- `-c <configure_options>:` extra parameters passed to the configure script.
- `-u`: if this flag is specified, the defined package (using `-f` or `-n`) will be uninstalled. The default behavior if `-u` is not specified, is to install the package.
- `-p <package_path>`: depreciated usage (instead use `setup.sh`). It defines the package path to keep the archive files.
- `-r <export_root>`: depreciated usage (instead use `setup.sh`). This directory is exported to the `$PATH` and `$LD_LIBRARY_PATH` environment variables.
- `-i <install_path>`: depreciated usage (instead use `setup.sh`). This directory contains the installed packages in separate directories each.
- `-j <cores>`: depreciated usage (instead use `setup.sh`). The number of cores for `make`.

Guessing the package name and filename:
- If the _filename_ of the archive is not given (using `-f`), `symin` tries to infer the _filename_ from the given URL (`-l`) or from the name (given by `-n`). - If _filename_ is not given and could not be inferred, `symin` reports an error.
- If an URL is specified and the _filename_ exists at the end of the URL, `-f` or `-n` are not required. Otherwise, _filename_ should be given using `-f`.
- If _filename_ is given (`-f`), and the _name_ of the unpacked archive exists in the _filename_ of the archive as _filename = name.extension_, where `extension` could be `tar.gz`, then, `symin` identifies the _name_ automatically. Otherwise, _name_ should be given using `-n`.
