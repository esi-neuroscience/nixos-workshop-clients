# nixos-workshop-clients

This repository will contain the instructions and configuration files, for a bootable NixOS.

# Important Notes! 

As the configuration files are all technically called `configuration.nix`, this would lead to confusion within the description of the steps performed and which file is used when, along with issues uploading the different configuration files. Therefore for this repository the files will be named `configuration_*.nix` where the `*` is the purpose of the configuration, e.g. `configuration_iso.nix` is the configuration file for creating the iso file of the live nixos.

This README will provide the steps taken to generate an ISO file for a live boot of NixOS from a usb. Then if the laptop that you want to install NixOS as the bootable OS is a UEFI boot you should follow the steps provided in [README](uefi_configuration/README.md), alternatively if you want to install the NixOS on a legacy boot laptop, you should follow the steps described in [README](bios_configuration/README.md). There are some slight differences in the steps required, and the configuration files.

You should also always be careful when installing a bootable OS onto your laptop. Make sure anything you want to save from your harddrive is backed up somewhere as the installation on the same disk/partition will wipe all the memory. 


# Requirements for the configuration file for creating the ISO file. 

Nix needs to be installed on the laptop you want to build the ISO file on, as the creation of the ISO file is dependent on the build commands from nix. 

Under your account (not as root) run:

```{bash}
sh <(curl -L https://nixos.org/nix/install)
```

This provides the nix installation, which you can activate using:
```{bash}
. ~/.nix-profile/etc/profile.d/nix.sh
```

Now you should have the nix commands available. 

For an iso file containing, a basic user account with no root permissions, a second account that does have sudo permissions, an automated login for the basic account, network setup, GNOME, and any specific packages you need, you can use the file [configuration_iso.nix](configuration_iso.nix) as a starting point, which is for a standard setup. Download and save it as `configuration.nix` inside a directory where you will also want to store the symlinked iso image. 

## Modifying the config
You can then modify it to fit your needs. The following explained settings are all within the example `configuration_iso.nix` file. In the example, a basic user account called `cobic` is defined, you can modify that by changing the line:

```{nix}
users.users.cobic
```

and change the cobic in the line to be your account name. You can also then setup an initial password for the user if you want, with the auto-login it won't be required but it is useful to have one. 

To have the graphical interface and not just a command line interface, you need to include:
```{nix}
services.xserver.enable = true;
services.xserver.desktopManager.gnome.enable = true;
```

In order to have a network connection, it is best to include the `networkmanager` option. However you should note that when you set `networking.networkmanager.enable = true;` then there tends to be a conflict with the `networking.wireless.enable` option. Therefore it should be in the form:

```{nix}
networking.networkmanager.enable = true;
networking.wireless.enable = false;
```

Finally for any additional packages that you would like to include in your ISO file you should include them within the `environment.systemPackages` option. If you don't know whether a package is available or not, you can check from the terminal using:

```{bash}
nix-env -qaP | grep turbovnc
```

where `turbovnc` represents the package.


# Building the ISO file
Once you have your `configuration.nix` file designed to suit your needs, you can build the iso image.

Plug in the USB that you want to use for the live boot. You can check the mounted location using 

```{bash}
lsblk
```

It is usually somewhere like `/dev/sdb` or something similar, it should be clear based on the available memory in comparison to your laptop/computer harddrive. 

You can generate the ISO image, in the same directory as where you have the `configuration.nix` file, using the following command:

```{bash}
NIX_PATH=nixpkgs=https://github.com/NixOS/nixpkgs/archive/<branch-name>.tar.gz nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./configuration.nix -o nix_config"
```

You should select a branch name, based on the version that suits your requirements best. 

If the installation of the nix commands or the generation of the iso image does not work as expected, there is an alternative method. It is possible to download the latest iso image from [https://nixos.org/download/](https://nixos.org/download/) for either the graphical or command line interfaces. Once you have installed the NixOS it is also possible to make changes to the configuration file, within the installation, at a later point.

In the case of building the iso file using github branch, the iso image will be symlinked with the name `nix_config`, which points to the `.iso` file that is located in the `/nix/store` directory. 


Once you usb is empty, making it the bootable ISO will overwrite everything on it so backup important information, you can unmount the USB.

### Warning: make sure you are pointing the following command at your USB!
The location can depend on the system, but before running the command ensure the `of=` part of the command is pointing to your USB and not your laptop/computer harddrive. You can change `/dev/sdb` to the location of the USB.

```{bash}
dd if=nix_config/iso/*iso of=/dev/sdb status=progress
```

This writes the ISO to your USB.

To confirm that everything has been setup, you can run:
```{bash}
sync
```

### For the steps to install the NixOS as the boot system on your additional laptop/computer you need to check if the boot system on the prospective computer is Legacy or or UEFI.

If you have a legacy boot system, you can find the configuration files [here](bios_configuration) and follow the steps in the [README](bios_configuration/README.md) linked.

Otherwise if you have a UEFI boot system, you can find the configuration files [here](uefi_configuration) and follow the steps in the [README](uefi_configuration/README.md) linked.

