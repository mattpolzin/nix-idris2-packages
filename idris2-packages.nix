{
  lib,
  fetchgit,
  system ? builtins.currentSystem or "unknown-system",
}:
let
  builtinPackages = [ "base" "contrib" "linear" "network" "papers" "prelude" "test" ];

  idris2Json = builtins.fromJSON (builtins.readFile ./idris2-pack-db/idris2.json);
  idris2Src = fetchgit idris2Json.src;

  idris2Pkg = import idris2Src;
  idris2 = idris2Pkg.default;
  buildIdris = idris2Pkg.buildIdris.${system};

  attrsToBuildIdris = packageName: attrs:
  buildIdris {
    inherit (attrs) ipkgName;
    src = fetchgit attrs.src;
    idrisLibraries = map (depName: packages.${depName}) (lib.subtractLists builtinPackages attrs.ipkgJson.depends);
  };

  packDbJson = builtins.fromJSON (builtins.readFile ./idris2-pack-db/pack-db-resolved.json);
  packages = lib.mapAttrs attrsToBuildIdris packDbJson;
in
{
  inherit idris2 buildIdris packages;
}
