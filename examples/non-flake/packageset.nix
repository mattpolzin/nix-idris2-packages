{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "69c416861bc9068ddda6be1ff25c9c90509844f9";
  hash = "sha256-l/cZ3x/hr9On4+rGOcEucJ8IzPpkqQOpXBqLsOutHVw=";
}) { inherit withSource; }
