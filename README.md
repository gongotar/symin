# symin
Symlink installer - a lightweight package manager for installations from sources on UNIX systems. 

**symin** performs different operations on packages, such as *install*, *uninstall*, *hide*, and *unhide* packages using symlink-style package management.
The operations do not need the root privileges and are performed locally under the *home* directory with a single command. 

**symin** is kept leightweight to make it available on most systems with minimum dependencies. 

## Sample Usages
First, execute `source setup.sh` to create the initial directories and configure the library and binary paths. 
Here you find some sample usages of `symin` to install, uninstall, hide (making the package temporarily unavailable to the system without uninstalling/destroying it), and unhide packages:
```bash
symin --url=https://ftp.gnu.org/gnu/bc/bc-1.07.tar.gz               # install from the URL (archive will be downloaded)
symin --file=bc-1.07.tar.gz                                         # install from the archive file (archive file should be available)
symin --file=gnuplot-5.4.2.tar.gz --config-params="--with-cairo"    # install from the archive and setting the configure parameters
symin --uninstall --name=neovim                                     # uninstall the neovim application (program identified by a part of its name)
symin --uninstall --executable=gnuplot                              # uninstall the gnuplot program (program identified by its executable)
symin --hide --name=python                                          # hides python3 without actually uninstalling it
symin --unhide --name=python                                        # undo hide a hidden application by (a part of) its name  
```

Notice that **symin** only supports GNU build system installations (`./configure & make & make install`) with the optional configure command. If necessary, `autogen.sh` is performed before `./configure`.


## Setup

To setup **symin** you can simply run `source setup`. More options of the setup script for special cases are as follows: 

`Usage: source setup.sh [ -p package_path ] [ -r export_root ] [ -i install_path ] [ -j cores ] [ -s installer_path ]`

You are good to go with the defaults and just performing `source setup.sh`. All flags are optional and `setup.sh` can be invoked without defining any flags. In the case of having specific requirements, please first refer to the section *Package Management* bellow to understand the setup parameters. The following flags can be adjusted to match with more specific usages. 
- `-p <package_path>`: defines the package path to keep the archive files.
- `-r <export_root>`: the directory that is exported to the `$PATH` and `$LD_LIBRARY_PATH` environment variables.
- `-i <install_path>`: the directory containing the installed packages in separate directories each.
- `-j <cores>`: the number of cores for `make`. This is automatically detected if not specified.
- `-s <installer_path>`: the path to the `symin` script.


## Using symin

```bash
Usage: symin
          [ --install ]                               # installs the specified package (default behavior)
          [ --uninstall ]                             # uninstalls the specified package
          [ --hide ]                                  # hides the specified package as if it is not installed
          [ --unhide ]                                # undo hides the specified package
          [ --url=<download url> ]                    # package download URL
          [ --file=<tar archive> ]                    # package archive file name
          [ --cores=<number of cores> ]               # number of cores to use for build
          [ --config-params=<configure parameters> ]  # parameters to be passed to ./configure
          [ --name=<package name> ]                   # the name of the package (or a part of its name)
          [ --executable=<program executable> ]       # an executable to specify a program for uninstall or hide
          [ --help | -h ]                             # prints this help message
 ```

Supported operations are:
<table>
<tr> 
<td>
                    
**install** (default): 
installs a package.<br>
  - to install a package, one of the following parameters must be set:<br>
    - *url*: the URL to download the package.<br>
    - *name*: the name (or a part of the name) of an already downloaded package (e.g., when a package is installed and then uninstalled, its archive file is kept). If more than one packages match with the name, the user will choose between the matching candidates.
    - *file*: the archive file of the package (locally available).<br>
  - optional parameters to install a package are as follows:<br>
    - *config-params* *(optional)*: parameters that to be passed to the `./configure` script.<br>
    - *cores* *(optional)*: number of cores available to build the package (`make -j<cores>`).
              
</td>
</tr>
<tr>
<td>

**uninstall:** 
uninstalls a package. To specify a package to be uninstalled, one of the following parameters must be set:
  - *executable*: an executable of the program to be uninstalled. The program is determined from the executable.
  - *name*: the name or a part of the name of the package to specify the target package. If more than one packages match with the name, the user will choose between the matching candidates.
          
</td>
</tr>
<tr> 
<td>
                    
**hide:**
makes a package (that is already installed) unavailable as if it's not installed, without actually uninstalling it. 
          
  - This operation hides the package on the system while it is still there safely. 
  - **symin** does not touch the package installation and only removes its symlinks (which can be recreated using *unhide*). 
  - This can be useful for some testing/expertimenting scenarios with the packages. 
  - To specify a package for hiding, one of the parameters *executable* or *name* must be set (see the discussion under the *uninstall* operation).
                    
</td>
</tr>
<tr>
<td>
                    
**unhide:** 
undo hides a hidden package to be available again on the system. 
  - To specify a hidden package, its *name* must be given. 
  - If more than one packages match with the name, the user will choose between the matching candidates. 
                    
</td>
</tr>
</table>

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
