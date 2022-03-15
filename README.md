# symin
Symlink Installer - A lightweight package manager for installations from sources on UNIX systems. 

**symin** performs different operations on packages, such as *install*, *uninstall*, *hide*, and *unhide* packages using symlink-style package management.
The operations do not need root privileges and are performed locally under the *home* directory with a single command. 

**symin** is kept leightweight to make it available on most systems with minimum dependencies. 

## Usage Samples
First, execute `source setup.sh` to create the initial directories and configure the library and binary paths. 
For installing/uninstalling a package, `symin` can be invoked as follows:
```bash
symin --url=https://ftp.gnu.org/gnu/bc/bc-1.07.tar.gz               # install from the URL (archive will be downloaded)
symin --file=bc-1.07.tar.gz                                         # install from the archive file (archive file should be available)
symin --file=gnuplot-5.4.2.tar.gz --config-params="--with-cairo"    # install from the archive and setting the configure parameters
symin --operation=uninstall --executable=gnuplot                    # uninstall the gnuplot program (program identified by its executable)
symin --operation=hide --executable=python3                         # hides python3 without actually uninstalling it (the whole python installation identified by its python3 executable)
symin --operation=unhide --qualified-name=gnuplot-5.4.2             # undo hide a hidden application by its qualified name  
```

Notice that **symin** only supports GNU build system installations (`./configure & make & make install`) with the optional configure command. If necessary, `autogen.sh` is performed before `./configure`.


## Setup

`Usage: source setup.sh [ -p package_path ] [ -r export_root ] [ -i install_path ] [ -j cores ] [ -s installer_path ]`

You are good to go with the defaults and just performing `source setup.sh`. All flags are optional and `setup.sh` can be invoked without defining any flags. In the case of having specific requirements, please first refer to the section *Package Management* bellow to understand the setup parameters. The following flags can be adjusted to match with more specific usages. 
- `-p <package_path>`: defines the package path to keep the archive files.
- `-r <export_root>`: the directory that is exported to the `$PATH` and `$LD_LIBRARY_PATH` environment variables.
- `-i <install_path>`: the directory containing the installed packages in separate directories each.
- `-j <cores>`: the number of cores for `make`. This is automatically detected if not specified.
- `-s <installer_path>`: the path to the `symin` script.

## Manual

```bash
Usage: symin
          [ --operation=<install | uninstall | hide | unhide> ]   # operation to be performed
          [ --url=<download url> ]                                # package download URL
          [ --file=<tar archive> ]                                # package archive file name
          [ --cores=<number of cores> ]                           # number of cores to use for build
          [ --config-params=<configure parameters> ]              # parameters to be passed to ./configure
          [ --executable=<program executable> ]                   # an executable to specify a program for uninstall or hide
          [ --qualified-name=<program qualified name> ]           # a unique name to specify a program for uninstall, hide, or unhide
          [ --help | -h ]                                         # prints this help message
 ```

Supported *operations* are:
- **install:** (default) installs a package.
  - to install a package, one of the following parameters must be set:
    - *url*: the URL to download the package.
    - *file*: the archive file of the package (locally available).
  - optional parameters to install a package are as follows:
    - *config-params* *(optional)*: parameters that to be passed to the `./configure` script.
    - *cores* *(optional)*: number of cores available to build the package (`make -j<cores>`).
- **uninstall:**: uninstalls a package. To specify a package to be uninstalled, one of the following parameters must be set:
  - *executable*: an executable of the program to be uninstalled. The program is determined from the executable.
  - *qualified-name*: a unique name that specifies the program. This is usually the name of the main folder after extracting the archive file. Usually it is consisted of the program name followed by its version. This is also the folder name where the program is installed to (under `<install_path>`, see below). Hence, calling `ls <install_path>` delivers the list of the qualified names of all programs installed by **symin**. For more information, see the section *Package Management*.
- **hide:** makes a package (that is already installed) unavailable without actually uninstalling it. This operation hides the package on the system while it is still there safely. **symin** does not touch the package installation and only removes its symlinks (which can be recreated using *unhide*). This can be useful for some testing/expertimenting scenarios with the packages. To specify a package for hiding, one of the parameters *executable* or *qualified-name* must be set (see the discussion under the *uninstall* operation).
  - after hiding a package, the *qualified-name* of the package will be reported. Use the *qualified-name* later when unhiding the package.
- **unhide:** undo hides a hidden package to be available again on the system. To specify a hidden package, its *qualified-name* must be given. This is reported  at the time the package was made hidden.

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
