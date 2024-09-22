let
  flakeLock = builtins.fromJSON (builtins.readFile ../flake.lock);
  rev = flakeLock.nodes.idris2Lsp.locked.rev;
  hash = flakeLock.nodes.idris2Lsp.locked.narHash;
  owner = flakeLock.nodes.idris2Lsp.locked.owner;
  repo = flakeLock.nodes.idris2Lsp.locked.repo;

  idris2Lsp = import (
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = hash;
    }
  );
in
{
  system,
}:
idris2Lsp.packages.${system}.idris2Lsp
