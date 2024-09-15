{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "6eb57073378f26a747210603ea4f3521591388d4";
  hash = "sha256-/5i359aDX8WDpNDDnMDO15Vc/e4xCmWKXTiHzNZfn9U=";
}) { inherit withSource; }
