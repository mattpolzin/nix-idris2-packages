{
  pkgs ? import <nixpkgs> {
    overlays = [ ];
    config = { };
  },
  withSource ? false,
}:
import (pkgs.fetchgit {
  url = "https://github.com/mattpolzin/nix-idris2-packages";
  rev = "d2ed7713115e74bad2d78ac9f73d083010028366";
  hash = "sha256-AE7a6ngPRbLLMn6DGH9GIaCWVEbqVVIRVU2rg+nj2eU=";
}) { inherit withSource; }
