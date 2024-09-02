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
in
{
  system,
  lib,
  fetchgit,
}:
let
  idris2Json = lib.importJSON ./idris2-pack-db/idris2.json;
  idris2Src = fetchgit idris2Json.src;
  idris2Pkg = import idris2Src;
in {
  idris2 = idris2Pkg.default; 
  buildIdris = idris2Pkg.buildIdris.${system};
  inherit builtinPackages;
}
