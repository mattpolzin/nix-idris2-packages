{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "73712315d3d0f15b931682137ae2032346302b67";
  hash = "sha256-0WS1Y69hV2Ik3nwJEdo6rxx8vcviUsVGGj8W0TNKCTY=";
}) { }
