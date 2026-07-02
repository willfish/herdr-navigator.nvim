{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        checks.default = pkgs.runCommand "herdr-navigator-nvim-check" { } ''
          mkdir -p "$out"
        '';

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            luajitPackages.luacheck
            neovim
            shellcheck
            shfmt
            stylua
          ];
        };
      }
    );
}
