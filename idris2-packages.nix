{
  lib,
  fetchgit,
  idris2Packages,
}:
let builtinPackages = [ "base" "contrib" "linear" "network" "papers" "prelude" "test" ];
  attrsToBuildIdris = packageName: attrs:
  idris2Packages.buildIdris {
    inherit (attrs) ipkgName;
    src = fetchgit (attrs.src // {deepClone = true;});
    idrisLibraries = map (depName: packages.${depName}) (lib.subtractLists builtinPackages attrs.ipkgJson.depends);
  };

  idris2Json = builtins.fromJSON (builtins.readFile ./idris2-pack-db/idris2.json);
  packDbJson = builtins.fromJSON (builtins.readFile ./idris2-pack-db/pack-db-resolved.json);
  packages = lib.mapAttrs attrsToBuildIdris packDbJson;
in packages
