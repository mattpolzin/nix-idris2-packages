{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
let
  packageset = import ./packageset.nix { inherit pkgs withSource; };
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
