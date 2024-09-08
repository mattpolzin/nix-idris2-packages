{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
let
  packageset = import ./packageset.nix { inherit pkgs; };
  pkg = packageset.buildIdris {
    ipkgName = "my-pkg";
    src = builtins.path {
      path = ./.;
      name = "my-ipkg-src";
    };
    idrisLibraries =
      let
        ps = packageset.idris2Packages;
      in
      [ ps.ncurses-idris ];
  };
in
pkg.executable
