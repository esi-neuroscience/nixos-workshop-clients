{ config, pkgs, ... }:

{
  # Bootloader (GRUB) configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";  # Adjust to the correct device for your boot disk

  # Define the root filesystem
  fileSystems."/" = {
    device = "/dev/sda1";  # This is where the NixOS root filesystem will be installed
    fsType = "ext4";  # Use the filesystem type that you formatted with (ext4)
  };

  fileSystems."/home/cobic" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" ];  # No need to specify a size
  };

  # Networking configuration 
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  networking.interfaces.<your-network-interface>.useDHCP = true; 
  networking.hostName = "<your-hostname>";
  
  # Time zone
  time.timeZone = "Europe/Berlin";

  # Users and default login
  users.users.cobic = {
    isNormalUser = true;
    initialPassword = "password";  # Replace with a secure password
  };

  users.users.nixos.group = "nixos";
  users.groups.nixos = {};
  users.users.nixos = {
    isSystemUser = true;  # NixOS user is a system user
    password = "root_password";  # Set root password for the nixos user
    extraGroups = [ "wheel" ];  # Give root-level permissions to nixos user
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "cobic";
  };

  # Packages to install (example: GNOME, TurboVNC)
  environment.systemPackages = with pkgs; [
    turbovnc
    vim
    git
    ];

  # GNOME services
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # System configurations
  system.stateVersion = "21.05";  # Specify the NixOS release
}
