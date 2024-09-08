# NOTE: Call this with idris2 and/or buildIdris overrides if you want to build
# packages using a different version of Idris2 than the most recent Pack
# package-set specifies. This can be useful but you are on your own in
# determining that all the packages you are going to need to build will support
# the Idris2 version you are using.
let
  brokenPackages = import ./idris2-pack-db/broken-packages.nix;
  packDb = import ./idris2-pack-db/pack-db.nix;
in
{
  lib,
  fetchgit,
  callPackage,
  system ? builtins.currentSystem or "unknown-system",
  idris2Override ? null,
  idris2LspOverride ? null,
  buildIdrisOverride ? null,
}:
let
  idris2Default = import ./idris2.nix { inherit system; };
  idris2LspDefault = import ./idris2-lsp.nix { inherit system; };

  idris2 = if idris2Override == null then idris2Default.idris2 else idris2Override;
  idris2Lsp = if idris2LspOverride == null then idris2LspDefault else idris2LspOverride;
  buildIdris = if buildIdrisOverride == null then idris2Default.buildIdris else buildIdrisOverride;
  idris2Api = import ./idris2-api.nix { inherit idris2 buildIdris; };

  inherit (idris2Default) builtinPackages;

  isBroken = packageName: builtins.elem packageName brokenPackages;

  overrides = callPackage ./idris2-pack-db/overrides.nix { };

  attrsToBuildIdris =
    packageName: attrs:
    let
      execOrLib = (p: if attrs.ipkgJson ? "executable" then p.executable else p.library { });
      idrisPackageAttrs = {
        inherit (attrs) ipkgName;
        version = attrs.ipkgJson.version or "unversioned";
        src = fetchgit (attrs.src // { fetchSubmodules = false; });
        idrisLibraries = map (depName: idris2Packages.${depName}) (
          lib.subtractLists builtinPackages attrs.ipkgJson.depends
        );
        meta.packName = attrs.packName;
        meta.broken = isBroken packageName;
      };
      override = overrides.${packageName} or { };
    in
    execOrLib (buildIdris (lib.recursiveUpdate idrisPackageAttrs override));

  idris2Packages = (lib.mapAttrs attrsToBuildIdris packDb) // {
    # The idris2-api package is named 'idris2':
    idris2 = idris2Api;
    # We build the LSP from its own repo's derivation:
    idris2-lsp = idris2Lsp;
  };
in
{
  inherit
    idris2
    idris2Lsp
    buildIdris
    idris2Packages
    ;
}
