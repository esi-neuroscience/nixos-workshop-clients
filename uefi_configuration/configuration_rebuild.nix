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
    device = "/dev/sda1";  # The root partition
    fsType = "ext4";  
  };

  # Define the root filesystem
  fileSystems."/" = {
    device = "/dev/sda2";  # The boot partition 
    fsType = "vfat";  
  };

  fileSystems."/home/cobic" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" ]; 
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
    vim
    git
  ];

  # GNOME services
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # System configurations
  system.stateVersion = "21.05";  # Specify the NixOS release
}
