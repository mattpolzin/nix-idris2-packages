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
  builtinPackages = [
    "base"
    "contrib"
    "linear"
    "network"
    "papers"
    "prelude"
    "test"
  ];

  idris2Json = lib.importJSON ./idris2-pack-db/idris2.json;
  idris2Src = fetchgit idris2Json.src;

  idris2Pkg = import idris2Src;
  idris2 = if idris2Override == null then idris2Pkg.default else idris2Override;
  buildIdris =
    if buildIdrisOverride == null then idris2Pkg.buildIdris.${system} else buildIdrisOverride;

  idris2Api =
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
      { };

  brokenPackages = lib.importJSON ./idris2-pack-db/broken.json;
  isBroken = (
    packageName:
    let
      depsBroken = lib.lists.any (
        p: builtins.elem p.meta.packName brokenPackages
      ) packages.${packageName}.propagatedIdrisLibraries;
    in
    builtins.elem packageName brokenPackages || depsBroken
  );

  attrsToBuildIdris =
    packageName: attrs:
    let
      execOrLib = (p: if attrs.ipkgJson ? "executable" then p.executable else p.library { });
    in
    execOrLib (buildIdris {
      inherit (attrs) ipkgName;
      version = attrs.ipkgJson.version or "unversioned";
      src = fetchgit attrs.src;
      idrisLibraries = map (depName: packages.${depName}) (
        lib.subtractLists builtinPackages attrs.ipkgJson.depends
      );
      meta.packName = attrs.packName;
      meta.broken = isBroken packageName;
    });

  packDbJson = lib.importJSON ./idris2-pack-db/pack-db-resolved.json;
  packages =
    (lib.mapAttrs attrsToBuildIdris packDbJson)
    //
    # The idris2-api package is named 'idris2':
    {
      idris2 = idris2Api;
    };
in
{
  inherit idris2 buildIdris packages;
}
