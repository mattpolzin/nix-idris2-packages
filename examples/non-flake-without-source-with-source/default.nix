{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
let
  packageset = import ./packageset.nix { inherit pkgs; };
  indexed =
    (packageset.experimental.buildIdris {
      src = pkgs.fetchFromGitHub {
        owner = "mattpolzin";
        repo = "idris-indexed";
        rev = "c99707f1db2efa2e97c465b16b525cb79b28f349";
        hash = "sha256-k31KQy5av3KwwXcAB8t6VgYWR8ukS8+k43MnQ1kG384=";
      };
      ipkgName = "indexed";
      idrisLibraries = [ ];
    }).library
      { };
  ncurses-idris =
    (packageset.experimental.buildIdris {
      src = pkgs.fetchFromGitHub {
        owner = "mattpolzin";
        repo = "ncurses-idris";
        rev = "e4faae7df3867d2d546d220dd9f9889ecda3cf6e";
        hash = "sha256-DpSaMahHR1DC+lVSH4iByO+t8t5Zpj4GmElJlN6AQLM=";
      };
      ipkgName = "ncurses-idris";
      idrisLibraries = [ indexed ];
      buildInputs = [ pkgs.ncurses.dev ];
    }).library
      { };
  pkg = packageset.experimental.buildIdris {
    ipkgName = "my-pkg";
    src = builtins.path {
      path = ./.;
      name = "my-ipkg-src";
    };
    idrisLibraries = [ ncurses-idris ];
  };
in
pkg.executable
