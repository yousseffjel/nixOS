# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  localPkgs = import ./packages/default.nix { pkgs = pkgs; };
in
{
  imports = [
    <home-manager/nixos>
    ./hardware/default.nix
    ./packages.nix
    ./overlays-system.nix
    ./modules/login.nix
    ./modules/torrent.home.nix
    ./modules/work.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = false;
  };

  services.udisks2.enable = true;

  programs.dconf.enable = true;

  # Fix hmr issue?
  systemd.extraConfig = ''DefaultLimitNOFILE=65536'';
  systemd.user.extraConfig = ''DefaultLimitNOFILE=65536'';
  boot.kernel.sysctl."fs.inotify.max_user_instances" = 8192;
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "65536";
    }
  ];

  # NOTE: Enable bluetooth using this and then use bluetoothctl
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable sound.
  sound.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  # Network
  networking = {
    hostName = "Antar";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8080 8081 3000 3001 ];
      allowedUDPPorts = [ 41641 ];
    };
    nameservers = [ "20.199.16.140" "8.8.8.8" "1.1.1.1" ];
    search = [ "resolve.construction" ];
    networkmanager.enable = true;
    extraHosts = ''
      127.0.0.1       phenax.local
      127.0.0.1       field.shape-e2e.com
    '';
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  services.atd.enable = true;

  virtualisation = {
    docker = {
      enable = true;
    };
    lxd.enable = false;
    virtualbox.host.enable = false;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
    # anbox.enable = true;
  };
  services.spice-vdagentd.enable = true;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = (with pkgs; [
      xdg-desktop-portal
      # xdg-desktop-portal-gtk
      xdg-desktop-portal-xapp
    ]);
    config = {
      common.default = "*";
    };
  };
  programs.darling.enable = false; # macos emu

  programs.tmux = {
    enable = true;
    secureSocket = true;
    terminal = "tmux-direct"; # st-256color
    shortcut = "0";
  };

  # I18n and keyboard layout
  time.timeZone = "Africa/Casablanca";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  # Home manager
  home-manager.users.yusuf = { pkgs, ... }: {
    imports = [ ./home.nix ];
    home = { stateVersion = "21.03"; };
  };

  # X11 config
  services.xserver = {
    enable = true;
    autorun = false;
    displayManager.startx.enable = true;
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        naturalScrolling = true;
      };
    };
  };
  fonts.packages = with pkgs; [
    # jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    cozette
    noto-fonts-emoji
  ];

  services.logind = {
    powerKey = "ignore";
    rebootKey = "ignore";
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    hibernateKey = "ignore";
    suspendKey = "ignore";
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  system.stateVersion = "20.09";
}
