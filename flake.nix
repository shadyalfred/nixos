{
  description = "Shady’s NixOS flake";

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations = {
      "nixos" = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        specialArgs = {
          pkgs = import nixpkgs {
            system = system;

            config.allowUnfree = true;
          };

          pkgs-unstable = import nixpkgs-unstable {
            system = system;

            config.allowUnfree = true;
          };
        };

        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
