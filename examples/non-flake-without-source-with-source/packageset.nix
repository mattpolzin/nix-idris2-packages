{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "135c6f96dbc52e2f8f3d8d88d70734bb2764079b";
  hash = "sha256-CTjWvT8L05ESKwAzR/hAvGhspaB9xkteU0pGn5quhJg=";
}) { inherit withSource; }
