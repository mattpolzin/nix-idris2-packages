{
  pkgs ? import ./nixpkgs.nix,
}:
let
  supportedPlatform = attrs: !(attrs.meta ? "platforms") || builtins.elem pkgs.stdenv.hostPlatform.config attrs.meta.platforms;
  packageset = pkgs.callPackage ./. { };
  packages = pkgs.lib.filterAttrs (n: attrs: !attrs.meta.broken && supportedPlatform attrs) packageset.idris2Packages;
in
pkgs.runCommand "all-packages"
  {
    nativeBuildInputs = pkgs.lib.attrValues packages;
  }
  ''
    echo ${toString (builtins.attrNames packages)} > $out
  ''
