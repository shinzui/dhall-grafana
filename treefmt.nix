{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.nixpkgs-fmt.enable = true;
  programs.dhall.enable = true;
}
