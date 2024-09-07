# NOTE: Call this with idris2 and/or buildIdris overrides if you want to build
# packages using a different version of Idris2 than the most recent Pack
# package-set specifies. This can be useful but you are on your own in
# determining that all the packages you are going to need to build will support
# the Idris2 version you are using.
let brokenPackages = import ./idris2-pack-db/broken-packages.nix;
    packDb = import ./idris2-pack-db/pack-db.nix;
in {
  lib,
  fetchgit,
  callPackage,
  system ? builtins.currentSystem or "unknown-system",
  idris2Override ? null,
  buildIdrisOverride ? null,
  idris2SupportOverride ? null,
}:
let
  idris2Default = import ./idris2.nix { inherit system; };

  idris2 = if idris2Override == null then idris2Default.idris2 else idris2Override;
  idris2Support = if idris2SupportOverride == null then idris2Default.support else idris2SupportOverride;
  buildIdris =
    if buildIdrisOverride == null then idris2Default.buildIdris else buildIdrisOverride;
  idris2Api = import ./idris2-api.nix { inherit idris2 buildIdris; };

  inherit (idris2Default) builtinPackages;

  isBroken = (
    packageName:
    let
      depsBroken = lib.lists.any (
        p: (p.meta.broken or false) || builtins.elem p.meta.packName brokenPackages
      ) packages.${packageName}.propagatedIdrisLibraries;
    in builtins.elem packageName brokenPackages || depsBroken
  );

  overrides = callPackage ./idris2-pack-db/overrides.nix {
    inherit idris2 idris2Support;
    idris2Packages = packages;
  };

  attrsToBuildIdris =
    packageName: attrs:
    let
      execOrLib = (p: if attrs.ipkgJson ? "executable" then p.executable else p.library { });
      idrisPackageAttrs = {
        inherit (attrs) ipkgName;
        version = attrs.ipkgJson.version or "unversioned";
        src = fetchgit (attrs.src // { fetchSubmodules = false; });
        idrisLibraries = map (depName: packages.${depName}) (
          lib.subtractLists builtinPackages attrs.ipkgJson.depends
        );
        meta.packName = attrs.packName;
        meta.broken = isBroken packageName;
      };
      override = overrides.${packageName} or {};
    in
    execOrLib (buildIdris (lib.recursiveUpdate idrisPackageAttrs override));

  packages =
    (lib.mapAttrs attrsToBuildIdris packDb)
    //
    # The idris2-api package is named 'idris2':
    {
      idris2 = idris2Api;
    };
in
{
  inherit idris2 buildIdris packages;
  idris2Lsp = packages.idris2-lsp;
}
