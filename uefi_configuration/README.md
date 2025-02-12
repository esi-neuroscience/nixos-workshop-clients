# Installing NixOS as a bootable OS on a laptop with a UEFI boot system

## Important Information!
If you have a UEFI boot system, and you have completed the steps in [README](../Documentation.md) to create the live ISO image on a USB, then you can continue with the installation of a bootable NixOS on your predetermined laptop. 

It is important to note, before continuing. You will need an internet connection on the laptop, as the installation requires copying from the nixos repository, and you should also make sure to backup anything that is important on the laptop currently. This is because the instructions that follow are for a single NixOS boot, and as a result includes wiping the main disk of the computer. Therefore any data currently stored there will be deleted.

You should also make sure that the boot sequence for the computer first looks for a USB OS to boot from. 

The installation on a UEFI boot system is relatively similar to that on a BIOS/Legacy version, with some important differences, both in the preparation and in the configuration files.

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

## Reformatting a UEFI boot partition to allow for installing the NixOS
UEFI boot systems traditionally have two partitions, a root partition and a boot partition. UEFI needs both of these partitions, which are generally in two different formats, inorder to correctly boot. The steps for modifying them are slightly different to the BIOS boot system. 

So the boot partition should be file system type of `fat32`, while the normal root partition should be `ext4`. You can check the partitions using `parted /dev/sda print`. 

If you need to set a boot partition, you can use the `parted` command. An example of how this is done is if you have the following output from your `parted /dev/sda print` command:

```
Number  Start   End     Size    File system  Name     Flags
 1      1MB     100GB   99GB    ext4         primary  boot, esp  
 2      100GB   100.5GB 500MB   fat32        primary  boot, esp 
```
where 1 and 2 represent sda1 and sda2 respectively, you only want one of the partitions to have the boot loader flag. Therefore you can run:

```{bash}
parted /dev/sda
set 1 boot off
set 1 esp off
set 2 boot on
set 2 esp on
print
quit
```

where the print helps with checking that the partitions have been updated. This will result in something like:

```
Number  Start   End     Size    File system  Name     Flags
 1      1MB     100GB   99GB    ext4         primary   
 2      100GB   100.5GB 500MB   fat32        primary  boot, esp 
```
***If*** you need to format the partitions at all you can use:

```
mkfs.ext4 /dev/sda1
mkfs.fat -F32 /dev/sda2
```

Now the mount paths are important for the actual installation. Using the above setup example you will need to mount `/dev/sda1` to `/mnt`, while creating a directory in `/mnt` 

```
mkdir -p /mnt/boot/efi
mount /dev/sda2 /mnt/boot/efi
```

Two configuration files are required for the installation. The first is the [harware_configuration.nix](hardware_configuration.nix). This just includes the two file systems and which partitions they are. The information is also to be included in the `configuration.nix` file.

Similar to the BIOS/Legacy build, you can then get take the [configuration_install.nix](configuration_install.nix) file from this subdirectory as a basis for your install. Change the name to `configuration.nix` after downloading and copy it and the `hardware_configuration.nix` to the created `/mnt/etc/nixos` subdirectory.

The configuration file includes some extra information, in addition to the basic information you want for your bootable OS, in comparison to the configuration file for Legacy/BIOS boot systems. This is to ensure that the boot is ready for UEFI. This includes:

```
  # Bootloader (GRUB) configuration
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
  };

  # Define the root filesystem
  fileSystems."/" = {
    device = "/dev/sda1"; 
    fsType = "ext4";  
  };

  # Define the root filesystem
  fileSystems."/" = {
    device = "/dev/sda2";  # The boot partition 
    fsType = "vfat";  
  };
```

You can then include any addition settings you would like to have in NixOS, including the DHCP IP method, or a hostname for your system.  This can be done by including the following in the configuration.nix file:

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
