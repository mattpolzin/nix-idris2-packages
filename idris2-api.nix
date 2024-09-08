{
  idris2,
  buildIdris,
}:
(buildIdris {
  inherit (idris2) src version;
  ipkgName = "idris2api";
  idrisLibraries = [ ];
  preBuild = ''
    export IDRIS2_PREFIX=$out/lib
    make src/IdrisPaths.idr
  '';
  meta.packName = "idris2";
}).library
  { }
