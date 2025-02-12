# Installing NixOS as the bootable OS on a laptop with a Legacy/BIOS boot system

## Important Information!
If you have a legacy/bios boot system, and you have completed the steps in [README](../README.md) to create the live ISO image on a USB, then you can continue with the installation of a bootable NixOS on your predetermined laptop. 

It is important to note, before continuing. You will need an internet connection on the laptop, as the installation requires copying from the nixos repository, and you should also make sure to backup anything that is important on the laptop currently. This is because the instructions that follow are for a single NixOS boot, and as a result includes wiping the main disk of the computer. Therefore any data currently stored there will be deleted.

You should also make sure that the boot sequence for the computer first looks for a USB OS to boot from. 

## Starting the live boot
If you have set your computer to search for the boot option from a USB, upon rebooting the laptop with the USB connected, you should see it boot into the NixOS. You can open a terminal, and it should show the user account name that you created with the hostname called nixos. Following the sample [configuration_iso.nix](../configuration_iso.nix) the user would show up in the terminal as follows:

```{bash}
cobic@nixos$
```

To make the changes needed for the installation to take place you need to check the disk and partition setup. You can check the partitions using:

```{bash}
lsblk
```

under your usual account, however to make changes you need to be root. If you have used a similar configuration for the ISO image as in the example then you should run:

```{bash}
su - nixos 
sudo -i
```

and change the `nixos` account name to whichever account you setup to have sudo permissions.

When you checked the partitions earlier you should have seen the main harddrive disk of the computer, possible under `/dev/sda`, and the USB disk, potentially under `/dev/sdb`. It is important to know which is which for the installation, as the main drive of the computer will be wiped for a single boot option of NixOS.

To see if there is anything remaining on the partition you are installing NixOS to, you can mount it and take a look. For wiping the partition though it is best if it is unmounted.

## Removing the current partition table and creating a new partition
One way of wiping the partition to make space for the NixOS installation is to delete the partition table for the main drive. As mentioned earlier, in this example the disk is `/dev/sda` and the partition will be `/dev/sda1`, so change this to the location of the main drive on your computer.

This can be done using `sfdisk`:
```{bash}
sfdisk --delete /dev/sda
```

Once the partition table is deleted for the main drive, you can check using `lsblk` and it should only show the disk now with no partitions. Now you need to create a new partition for the OS. 

```{bash}
echo ",,83" | sfdisk /dev/sda
```

Now if you look at the partition table, it should show an empty partition on the disk that is the same size as the disk itself. The partition needs to now be formatted so that it can be used for booting NixOS. 

```{bash}
mkfs.ext4 /dev/sda1
```

You will also need to make sure that the new partition is bootable. 
```{bash}
fdisk /dev/sda
p
a
p
w
```

The `fdisk /dev/sda` allows you to make changes to the partitions on the drive. By typing `p` it sends you to the partitions, `a` makes the partition bootable, `w` writes the changes and saves them.

You can double check that the partition is now bootable by running:
```{bash}
fdisk -l /dev/sda
```

## Installing the NixOS
Once your partition for the installation is ready, you can mount it under `/mnt`, and create the following subdirectory in it.

```{bash}
mount /dev/sda1 /mnt
mkdir -p /mnt/etc/nixos
```

Now download the [configuration_install.nix](configuration_install.nix) from the repository and save it under the name `configuration.nix` within `/mnt/etc/nixos`. Here you can make any changes to it for your installation of NixOS. 

There are some important options that need to be included in the `configuration.nix` file for NixOS to be the bootable OS on your system. 
```{nix}
boot.loader.grub.enable = true;
boot.loader.grub.device = "/dev/sda";

fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
};
```

This ensures that the bootloader is included and it points to the partition for the OS installation. Some additional settings can also be added into the configuration file for the installation including: setting up the type of network connection, e.g. the method for the IP address to be DHCP, or setting a hostname for your computer. This can be done by including the following in the configuration.nix file:

```{nix}
networking.interfaces.<your-network-interface>.useDHCP = true;
networking.hostName = "<your-hostname>";
```

and swapping out `<your-network-interface>` and `<your-hostname>` for which ever network interface you have a connection over currently, and a hostname you want to call the computer respectively.

With the configuration script located in `/mnt/etc/nixos` and all of your settings specified, you can now run the installation.

```{bash}
nixos-install --root /mnt
```

At the end of the installation you will be asked to set the root password. This is the password you will use if you need to login as root at any point to make changes to the installation.

Now you can restart your system and remove the USB. Upon reboot, it should automatically boot into the NixOS.

## Editing your installation

If your laptop is already booting into the NixOS, you can always make edits to the configuration e.g. changing the time zone, or making the user (in our example `cobic`'s) home directory temporary as in it resets with every reboot.

Examples of these edits are included in the [configuration_rebuild.nix](configuration_rebuild.nix) file. These edits can simply be copied into your `configuration.nix` file that is stored under `/etc/nixos`. You will need to be root to make these edits, and to run the rebuild.

Once you have finished making the edits to the configuration you can run:
```{bash}
nixos-rebuild switch
```

The changes will take effect when you restart the computer.

## Updating the version of NixOS that is installed
If you want to upgrade your version of NixOS from the one you installed, it can be run under the root account. 

To check what version you currently have installed:
```{bash}
nixos-version
```

Say you have version 21.05 and want to upgrade it to version 23.11

```{bash}
nix-channel --add https://nixos.org/channels/nixos-23.11 nixos
nix-channel --update
```

Now for the upgraded version to take effect, rebuild the configuration.
```{bash}
nixos-rebuild switch --upgrade
```
