{
  description = "Minimal Python + uv + direnv template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    uv2nix.url = "github:pyproject-nix/uv2nix";
  };

  outputs = { self, nixpkgs, flake-utils, uv2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ uv2nix.overlay ];
        };

        pythonEnv = pkgs.uv.buildEnv {
          src = ./.;
          python = pkgs.python312;
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.direnv
            pkgs.uv
            pythonEnv
          ];
          shellHook = ''
            echo "🐍 Python environment ready (via Nix and uv2nix)"
          '';
        };
      });
}
