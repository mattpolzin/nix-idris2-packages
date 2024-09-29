{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "4517c569f4e70a1b87168681f95bff9b42aea37a";
  hash = "sha256-ESuFlTp07N92Iv8ZF5uYor0XcrqH2VSytXM5fQ5tVyw=";
}) { inherit withSource; }
