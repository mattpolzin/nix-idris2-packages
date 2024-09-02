{
  pkgs ? import <nixpkgs> {},
  idris2 ? null,
  buildIdris ? null,
}:
pkgs.callPackage ./idris2-packages.nix { idris2Override = idris2; buildIdrisOverride = buildIdris; }
