{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "88d41056edb1f432bd9356996a370bbec6fe5831";
  hash = "sha256-PlUn84WYCpqwrM7egmGkyx5sQGvEWZvEmVwdqwkJcj4=";
}) { inherit withSource; }
