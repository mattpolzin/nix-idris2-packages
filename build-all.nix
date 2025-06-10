{
  pkgs ? import ./packages/nixpkgs.nix,
}:
let
  inherit (pkgs) lib stdenv callPackage;
  packageset = callPackage ./. { };

  inherit (packageset) idris2Packages;

  supportedPlatform =
    attrs: !(attrs.meta ? "platforms") || builtins.elem stdenv.hostPlatform.config attrs.meta.platforms;

  depsSupported =
    p: lib.lists.all (p: supportedPlatform p) p.propagatedIdrisLibraries;

  depsBroken =
    p: lib.lists.any (p: (p.meta.broken or false) || depsBroken p) p.propagatedIdrisLibraries;

  packages = lib.filterAttrs (
    n: p: (lib.isDerivation p) && !p.meta.broken && !(depsBroken p) && supportedPlatform p && depsSupported p
  ) idris2Packages.packdb;

    packageNames = builtins.attrNames packages;
in
pkgs.runCommand "all-packages"
  {
    nativeBuildInputs = lib.attrValues packages;

    passthru = { inherit packages packageNames; };
  }
  ''
    echo ${toString packageNames} > $out
  ''
