{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
let
  packageset = import ./packageset.nix { inherit pkgs withSource; };
in
packageset.buildIdris' {
  ipkgName = "my-pkg";
  src = builtins.path {
    path = ../shared-src;
    name = "my-ipkg-src";
  };
}
