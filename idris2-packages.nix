# NOTE: Call this with idris2 and/or buildIdris overrides if you want to build
# packages using a different version of Idris2 than the most recent Pack
# package-set specifies. This can be useful but you are on your own in
# determining that all the packages you are going to need to build will support
# the Idris2 version you are using.
{
  lib,
  fetchgit,
  system ? builtins.currentSystem or "unknown-system",
  idris2Override ? null,
  buildIdrisOverride ? null,
}:
let
  builtinPackages = [ "base" "contrib" "linear" "network" "papers" "prelude" "test" ];

  idris2Json = builtins.fromJSON (builtins.readFile ./idris2-pack-db/idris2.json);
  idris2Src = fetchgit idris2Json.src;

  idris2Pkg = import idris2Src;
  idris2 = if idris2Override == null then idris2Pkg.default else idris2Override;
  buildIdris = if buildIdrisOverride == null then idris2Pkg.buildIdris.${system} else buildIdrisOverride;

  attrsToBuildIdris = packageName: attrs:
  let execOrLib = (p: if attrs.ipkgJson ? "executable" then p.executable else p.library {});
  in execOrLib (buildIdris {
    inherit (attrs) ipkgName;
    version = attrs.ipkgJson.version or "unversioned";
    src = fetchgit attrs.src;
    idrisLibraries = map (depName: packages.${depName}) (lib.subtractLists builtinPackages attrs.ipkgJson.depends);
  });

  packDbJson = builtins.fromJSON (builtins.readFile ./idris2-pack-db/pack-db-resolved.json);
  packages = lib.mapAttrs attrsToBuildIdris packDbJson;
in
{
  inherit idris2 buildIdris packages;
}
