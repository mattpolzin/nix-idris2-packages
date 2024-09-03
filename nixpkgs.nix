let flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  rev = flakeLock.nodes.nixpkgs.locked.rev;
  hash = flakeLock.nodes.nixpkgs.locked.narHash;
  owner = flakeLock.nodes.nixpkgs.locked.owner;
  repo = flakeLock.nodes.nixpkgs.locked.repo;
in
import (builtins.fetchTarball {
  url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
  sha256 = hash;
}) {}
