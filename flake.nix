{
  description = "dhall-grafana - Dhall types for generating Grafana dashboards";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, pre-commit-hooks, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        treefmtEval = treefmt-nix.lib.evalModule pkgs (import ./treefmt.nix { inherit pkgs; });
        formatter = treefmtEval.config.build.wrapper;
      in
      {
        formatter = formatter;

        checks = {
          formatting = treefmtEval.config.build.check self;
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              treefmt.package = formatter;
              treefmt.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.dhall-json
            pkgs.process-compose
            pkgs.just
            pkgs.jq
            pkgs.curl
            pkgs.fswatch
            pkgs.grafana
            pkgs.prometheus
            pkgs.check-jsonschema
          ];

          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}

            mkdir -p .dev
            mkdir -p out

            # Grafana paths — absolute so grafana.ini $__env{} interpolation works
            export GRAFANA_HOME="${pkgs.grafana}/share/grafana"
            export DATA_PATH="$PWD/.dev/grafana"
            export CONFIG_PATH="$PWD/grafana"
            export DASHBOARDS_PATH="$PWD/out"

            mkdir -p "$DATA_PATH"
          '';
        };
      }
    );
}
