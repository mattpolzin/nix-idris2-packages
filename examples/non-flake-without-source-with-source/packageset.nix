{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "a1319bac424e7c1005ca676ddfdf0b73e0e17e1d";
  hash = "sha256-v5KP15EBoDsNR1QhwOSRWTIDsNBqTcdiOAUK9/4xMos=";
}) { inherit withSource; }
