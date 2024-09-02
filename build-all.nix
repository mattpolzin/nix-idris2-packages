{ pkgs ? import <nixpkgs> {} }:
let idris2Packages = pkgs.callPackage ./. {};
in pkgs.runCommand "all-packages" {
  nativeBuildInputs = pkgs.lib.attrValues idris2Packages.packages;
} ''
  echo ${toString (builtins.attrNames idris2Packages.packages)} > $out
''
