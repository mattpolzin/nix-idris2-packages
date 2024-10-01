{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
let
  packageset = import ./packageset.nix { inherit pkgs; };
in
packageset.experimental.buildIdris' {
  ipkgName = "my-pkg";
  src = builtins.path {
    path = ../shared-src;
    name = "my-ipkg-src";
  };
}
