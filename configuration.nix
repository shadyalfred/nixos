# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).
{
  nixpkgs,
  pkgs,
  pkgs-unstable,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.registry.nixpkgs.flake = nixpkgs;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Africa/Cairo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_AU.UTF-8";
    };
  };
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  services.logind.lidSwitch = "ignore";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    khelpcenter
  ];

  # Configure keymap in X11
  services.xserver = {
    exportConfiguration = true;

    xkb = {
      layout = "us,ara";
      variant = ",digits";
      options = "compose:ralt,grp:win_space_toggle";
    };
  };
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver = {
    inputClassSections = [
      ''
        Identifier "Stick Speed"
        MatchProduct "AlpsPS/2 ALPS DualPoint Stick"
        Option "libinput Accel Speed" "0.8"
      ''
    ];

    libinput = {
      enable = true;

      touchpad = {
        accelProfile = "flat";
        tappingButtonMap = "lmr";
        disableWhileTyping = true;
        additionalOptions = ''
          Option "PalmDetection" "on"
        '';
      };
    };
  };
  hardware.trackpoint = {
    enable = true;
    speed = 205;
  };
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTR{name}=="AlpsPS/2 ALPS DualPoint Stick", ATTR{device/drift_time}="30"
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shady = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "syncthing"
    ];
    packages = with pkgs; [
      syncthing
    ];
  };

  # Add your own username to the trusted list
  nix.settings.trusted-users = ["shady"];

  programs.zsh = {
    enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";

    autosuggestions.enable = true;

    syntaxHighlighting.enable = true;
    syntaxHighlighting.highlighters = [
      "main"
      "root"
    ];
  };

  users.defaultUserShell = pkgs.zsh;

  programs.direnv.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git

    zsh
    zsh-powerlevel10k
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    emacs

    alejandra
    nil

    glxinfo

    gcc

    linuxKernel.packages.linux_6_1.nvidia_x11_legacy390

    parted
    pciutils

    ripgrep
    fzf
    fd
    curl
    wget
    zip
    unzip
    mediainfo
    file

    nnn

    keyd

    neofetch

    libsForQt5.applet-window-buttons
    libsForQt5.bismuth
    libsForQt5.breeze-gtk
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.kdeconnect-kde
    ghostscript # pdf thumbnail dolphin

    (catppuccin-kvantum.override {
      accent = "Blue";
      variant = "Mocha";
    })
    (catppuccin-gtk.override {
      variant = "mocha";
      accents = ["blue"];
    })
    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "blue";
    })

    aspell
    aspellDicts.ar
    aspellDicts.en
    aspellDicts.en-science
    aspellDicts.en-computers

    hunspell
    hunspellDicts.en_US

    xsel
    xclip

    wezterm
    kitty
    libsForQt5.yakuake

    partition-manager
    exiftool

    keepassxc

    firefox
    brave
    microsoft-edge
    tor-browser-bundle-bin

    qbittorrent

    discord
    element-desktop
    telegram-desktop

    yt-dlp

    ffmpeg

    mpv
    vlc

    thunderbird

    pkgs-unstable.neovide

    libqalculate

    foliate

    libsForQt5.kolourpaint
    gimp

    pkgs-unstable.obsidian

    exercism

    nicotine-plus

    libreoffice-qt

    xiphos

    bottles

    mupen64plus
  ];

  environment.variables.EDITOR = "nvim";
  environment.shells = with pkgs; [zsh];
  environment.sessionVariables.ZDOTDIR = "$HOME/.config/zsh/";

  environment.shellAliases = {
    nnn = "nnn -Tt";
  };

  environment.variables = {
    NNN_FIFO = "/tmp/nnn.fifo";
    NNN_PLUG = "p:preview-tui";
    BROWSER = "brave";
  };

  environment.etc = {
    "keyd/default.conf".source = ./cfg/keyd.conf;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-lgc-plus
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji

      inter
      cantarell-fonts

      liberation_ttf
      garamond-libre
      eb-garamond

      ibm-plex
      fira-code
      meslo-lgs-nf

      (nerdfonts.override { fonts = [
        "FiraCode"
        "FiraMono"
        "JetBrainsMono"
        "IBMPlexMono"
        "Iosevka"
        "IosevkaTerm"
        "CascadiaCode"
        "Meslo"
        "Hack"
        "Overpass"
        "SpaceMono"

        "NerdFontsSymbolsOnly"
      ]; })

      emacs-all-the-icons-fonts
    ];

    fontconfig = {
      antialias = true;
      hinting = {
        enable = true;
        style = "full";
        autohint = true;
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };

      defaultFonts = {
        serif = ["IBM Plex Serif" "Noto Serif"];
        sansSerif = ["IBM Plex Sans" "Noto Sans"];
        monospace = ["IBM Plex Mono"];
      };
    };
  };

  systemd.services.keyd = {
    enable = true;
    description = "keyd key remapping daemon";
    wantedBy = ["sysinit.target"];
    unitConfig = {
      Requires = "local-fs.target";
      After = "local-fs.target";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.keyd}/bin/keyd";
    };
  };

  security.pam.services.sddm.enableKwallet = true;

  programs.dconf.enable = true;

  services.syncthing = {
    enable = true;
    user = "shady";
    openDefaultPorts = true;
    dataDir = "/home/shady/.config/syncthing";
    configDir = "/home/shady/.config/syncthing";
  };

  networking.firewall.allowedTCPPorts = [
    # Syncthing
    8384
    22000
  ];
  networking.firewall.allowedUDPPorts = [
    # Syncthing
    22000
    21027
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # KDE Connect
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1714;
      to = 1764;
    } # KDE Connect
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
