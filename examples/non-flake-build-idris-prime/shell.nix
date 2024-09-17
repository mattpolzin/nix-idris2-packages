{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
let
  packageset = import ./packageset.nix {
    inherit pkgs;
    withSource = true;
  };
  myPkg = import ./. {
    inherit pkgs;
    withSource = true;
  };
in
pkgs.mkShell {
  packages = [
    packageset.idris2
    packageset.idris2Lsp
  ];
  inputsFrom = [ myPkg ];
}
