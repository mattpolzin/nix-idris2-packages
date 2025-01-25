{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
let
  packageset = import ./packageset.nix { inherit pkgs; };
in
packageset.buildIdris' {
  ipkgName = "my-pkg";
  src = builtins.path {
    path = ../shared-src;
    name = "my-ipkg-src";
  };
}
