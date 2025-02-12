{ config, pkgs, ... }:

{
  # Import the standard minimal ISO configuration
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix> ];
  
  # Create a user named "user" with no root privileges
  users.users.cobic = {
    isNormalUser = true;
    initialPassword = "password"; # Set an initial password
  };

  # Make the user the default login account for graphical session
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "cobic";
  };

  # Create a root user with password "nixos"
  users.users.nixos = {
    initialPassword = "root_password"; # root password
  };

  # Enable the X server and install GNOME
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Disable wireless network manager and wireless support
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  # Alternatively, you can install TurboVNC
  environment.systemPackages = with pkgs; [
    turbovnc
  ];

}

