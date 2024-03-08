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
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: {
    nixosConfigurations = {
      "nixos" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          pkgs = import nixpkgs {
            system = system;

            config.allowUnfree = true;
            config.nvidia.acceptLicense = true;
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
