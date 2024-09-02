{
  pkgs ? import ./nixpkgs.nix,
}:
let
  idris2Packages = pkgs.callPackage ./. { };
  packages = pkgs.lib.filterAttrs (n: attrs: !attrs.meta.broken) idris2Packages.packages;
in
pkgs.runCommand "all-packages"
  {
    nativeBuildInputs = pkgs.lib.attrValues packages;
  }
  ''
    echo ${toString (builtins.attrNames packages)} > $out
  ''
