let flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  rev = flakeLock.nodes.nixpkgs.locked.rev;
  hash = flakeLock.nodes.nixpkgs.locked.narHash;
in
import (builtins.fetchTarball {
  url = "https://github.com/nixos/nixpkgs/archive/${rev}.tar.gz";
  sha256 = hash;
}) {}
