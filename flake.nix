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
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
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
              (final: prev: {linuxPackages = prev.linuxPackages_6_1;})

              (final: prev: {nvidia_x11 = prev.linuxKernel.packages.linux_6_1.nvidia_x11_legacy390;})

              (final: prev: {
                primusLib = prev.primusLib.override (old: {
                  nvidia_x11 = prev.linuxKernel.packages.linux_6_1.nvidia_x11_legacy390;
                });
              })

              (final: prev: {
                bumblebee = prev.bumblebee.override (old: {
                  nvidia_x11 = prev.linuxKernel.packages.linux_6_1.nvidia_x11_legacy390;
                  extraNvidiaDeviceOptions = "BusID \"PCI:1:0:0\"";
                });
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
                  nvidia_x11s = [prev.linuxKernel.packages.linux_6_1.nvidia_x11_legacy390];

                  nativeBuildInputs =
                    old.nativeBuildInputs
                    ++ [
                      prev.xorg.xf86inputmouse
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
        };

        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
  };
}
