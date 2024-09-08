{
  pkgs ? import ./nixpkgs.nix,
}:
let
  inherit (pkgs) lib stdenv callPackage;
  packageset = callPackage ./. { };

  inherit (packageset) idris2Packages;

  supportedPlatform = attrs: !(attrs.meta ? "platforms") || builtins.elem stdenv.hostPlatform.config attrs.meta.platforms;

  depsBroken = p: lib.lists.any (p: (p.meta.broken or false) || depsBroken p) p.propagatedIdrisLibraries;

  packages = lib.filterAttrs (n: p: !p.meta.broken && !(depsBroken p) && supportedPlatform p) idris2Packages;
in
pkgs.runCommand "all-packages"
  {
    nativeBuildInputs = lib.attrValues packages;
  }
  ''
    echo ${toString (builtins.attrNames packages)} > $out
  ''
