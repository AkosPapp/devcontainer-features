{
  description = "Flake with statically built Nix as default package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    alejandra,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages.nix = (
          (
            pkgs.pkgsStatic.nix.override (old: {
              enableStatic = true;
              enableDocumentation = false;
            })
          )
.overrideAttrs (old: {
            checkPhase = ''
              return 0
            '';
          })
        );

        packages.default = pkgs.stdenv.mkDerivation {
          name = "nix-multi-arch";
          src = null;

          phases = ["installPhase"];

          installPhase = [''
            mkdir -p $out
          ''] ++
          (
          pkgs.lib.map  (sys : ''
          mkdir -p $out/${sys}
          cp -r ${self.packages.${sys}.nix}/bin ${self.packages.${sys}.nix}/share $out/${sys}
          '') [ "x86_64-linux" "aarch64-linux" ]
          );
        };

        formatter = alejandra.defaultPackage.${system};
      });
}
