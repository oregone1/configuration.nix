# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  hardware.rtl-sdr.enable = true;

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    kernelModules = [ "v4l2loopback" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4"; 
  };

  networking = {
    hostName = "W530";
    hostId = "07b4a35f";
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
    ];
  };

  time.timeZone = "America/Los_Angeles";
  
  # for pipewire
  security.rtkit.enable = true;

  services = {
    openssh = {
      enable = true;
      forwardX11 = true;
      # add key auth stuff
    };

    xserver = {
      enable = true;
      autorun = false;
      layout = "dvorak";
      windowManager.i3 = {
        enable = true;
      };
      displayManager.sx = {
        enable = true;
      };
      libinput.enable = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };
  };

  fonts.fonts = [
    pkgs.nerdfonts
    pkgs.source-code-pro
    pkgs.font-awesome_5
    pkgs.cm_unicode
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  programs = {
    bash = {
     shellInit = ''
     	eval "$(starship init bash)"
     '';
     enableCompletion = true;
   };
  };

  users.users.natalie = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "plugdev" ]; 
  };

  environment.systemPackages = with pkgs; [
    vim 
    wget
    xterm
    i3blocks
    xorg.xkill
    xorg.xkbcomp
    xorg.xkbprint
    home-manager
    starship
    curl 
    git 
    jq
    yq
  ];

  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
