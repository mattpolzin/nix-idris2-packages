let
  builtinPackages = [
    "base"
    "contrib"
    "linear"
    "network"
    "papers"
    "prelude"
    "test"
  ];

  flakeLock = builtins.fromJSON (builtins.readFile ../flake.lock);
  rev = flakeLock.nodes.idris2.locked.rev;
  hash = flakeLock.nodes.idris2.locked.narHash;
  owner = flakeLock.nodes.idris2.locked.owner;
  repo = flakeLock.nodes.idris2.locked.repo;

  idris2 = import (
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = hash;
    }
  );
in
{
  system,
}:
{
  support = idris2.packages.${system}.support;
  idris2 = idris2.packages.${system}.idris2;
  buildIdris = idris2.buildIdris.${system};
  inherit builtinPackages;
}
