{
  nixpkgs ? import <nixpkgs> {}
}:
nixpkgs.callPackage ./idris2-packages.nix { }
