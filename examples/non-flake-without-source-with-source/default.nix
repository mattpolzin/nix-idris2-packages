{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
let
  packageset = import ./packageset.nix { inherit pkgs; };
  pkg = packageset.experimental.buildIdris' {
    ipkgName = "my-pkg";
    src = builtins.path {
      path = ./.;
      name = "my-ipkg-src";
    };
  };
in
pkg
