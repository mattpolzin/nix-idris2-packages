{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "5ce9f4764bb20fef00520c6bc108453085b40883";
  hash = "sha256-py4/g7gFFjVcqIWiKGmtcH57pORD1TlXbhbjhSAw7Ac=";
}) { }
