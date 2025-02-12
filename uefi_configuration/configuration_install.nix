{ config, pkgs, ... }:

{
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
    device = "/dev/sda1";  # The partition where the NixOS root filesystem will be installed (potentially different for each user)
    fsType = "ext4";  # Use the filesystem type that you formatted with (ext4)
  };

  # Define the root filesystem
  fileSystems."/" = {
    device = "/dev/sda2";  # The boot partition 
    fsType = "vfat";  # Use the filesystem type that you formatted with (ext4)
  };

  # Networking configuration (static IP)
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  networking.interfaces.<your-network-interface>.useDHCP = true;
  networking.hostName = "<your-hostname>";

  # Users and default login
  users.users.cobic = {
    isNormalUser = true;
    initialPassword = "password";  # Replace with a secure password
  };

  users.users.nixos = {
    isSystemUser = true; 
    password = "root_password";  
    extraGroups = [ "wheel" ]; 
  };

  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "cobic";
  };

  # Packages to install (example: GNOME, TurboVNC)
  environment.systemPackages = with pkgs; [
    turbovnc
  ];

  # GNOME services
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # System configurations
  system.stateVersion = "21.05";  # Specify the NixOS release
}
