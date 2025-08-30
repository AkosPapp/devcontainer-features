{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      devshell = pkgs.mkShell {
        buildInputs = [pkgs.hello];
      };
    in {
      devShells.default = devshell;
      packages.default = devshell;

      formatter = pkgs.alejandra;
    });
}
