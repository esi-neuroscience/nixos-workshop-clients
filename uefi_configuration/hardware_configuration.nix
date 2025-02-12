{ config, pkgs, ... }:
{
  # Define the root filesystem
  fileSystems."/" = {
    device = "/dev/sda1";  # The partition where the NixOS root filesystem will be installed (potentially different for each user)
    fsType = "ext4";  # Use the filesystem type that you formatted with (ext4)
  };

  # Define the root filesystem
  fileSystems."/" = {
    device = "/dev/sda2";  # The boot partition 
    fsType = "vfat";  # Use the filesystem type that you formatted with (ext4)
  };
}