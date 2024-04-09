{
  description = "Shady’s NixOS flake";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];

    substituters = [
      "https://cache.nixos.org/"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];

    extra-substituters = [
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    allowUnfree = true;
  };

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    sddm-catppuccin.url = "github:khaneliman/sddm-catppuccin";
    sddm-catppuccin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    sddm-catppuccin,
    ...
  } @ inputs: {
    nixosConfigurations = {
      "nixos" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = rec {
          inherit (inputs) nixpkgs;

          pkgs = import nixpkgs {
            system = system;

            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;

            overlays = [
              (final: prev: {
                bumblebee = prev.bumblebee.override {
                  nvidia_x11 = pkgs.linuxKernel.packages.linux_6_1.nvidia_x11_legacy390;
                  extraNvidiaDeviceOptions = "BusID \"PCI:1:0:0\"";
                };
              })

              (final: prev: let
                xmodules = pkgs.lib.concatStringsSep "," (
                  map (x: "${x.out or x}/lib/xorg/modules") [
                    pkgs.xorg.xorgserver
                    pkgs.xorg.xf86inputmouse
                  ]
                );
              in {
                bumblebee = prev.bumblebee.overrideAttrs (old: {
                  nativeBuildInputs =
                    old.nativeBuildInputs
                    ++ [
                      pkgs.xorg.xf86inputmouse
                    ];
                  CFLAGS = [
                    "-DX_MODULE_APPENDS=\\\"${xmodules}\\\""
                  ];
                });
              })
            ];
          };

          pkgs-unstable = import nixpkgs-unstable {
            system = system;

            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;
          };

          sddm-catppuccin = inputs.sddm-catppuccin;
        };

        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
  };
}
