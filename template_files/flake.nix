{
  description = "Minimal Python + uv + direnv template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python312;
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            python
            pkgs.direnv
          ];
          shellHook = ''
            echo "🐍 Python environment ready (via Nix)"
          '';
        };
      });
}
