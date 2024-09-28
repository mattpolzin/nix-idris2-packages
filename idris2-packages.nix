# NOTE: Call this with idris2 and/or buildIdris overrides if you want to build
# packages using a different version of Idris2 than the most recent Pack
# package-set specifies. This can be useful but you are on your own in
# determining that all the packages you are going to need to build will support
# the Idris2 version you are using.
let
  packDb = import ./idris2-pack-db/pack-db.nix;
in
{
  lib,
  fetchgit,
  callPackage,
  system ? builtins.currentSystem or "unknown-system",
  idris2Override ? null,
  idris2SupportOverride ? null,
  idris2LspOverride ? null,
  buildIdrisOverride ? null,
  # Call with `withSource = true` to get jump-to-definition support with editor tooling.
  withSource ? false,
}:
let
  idris2Default = import ./packages/idris2.nix { inherit system; };
  idris2LspDefault = import ./packages/idris2-lsp.nix { inherit system; };

  idris2 = if idris2Override == null then idris2Default.idris2 else idris2Override;
  idris2Support =
    if idris2SupportOverride == null then idris2Default.support else idris2SupportOverride;
  idris2Lsp = if idris2LspOverride == null then idris2LspDefault else idris2LspOverride;
  buildIdris = if buildIdrisOverride == null then idris2Default.buildIdris else buildIdrisOverride;
  idris2Api = import ./packages/idris2-api.nix { inherit idris2 buildIdris; };

  buildIdris' = callPackage ./build-idris-prime.nix { inherit idris2 idris2Packages buildIdris; };
  buildIdrisAlpha = callPackage ./build-idris-alpha.nix {
      inherit idris2;
      idris2Version = idris2.version;
      support = idris2Support;
    };

  experimental = {
    buildIdris = buildIdrisAlpha;
    buildIdris' = buildIdris'.override { buildIdris = buildIdrisAlpha; };
  };

  inherit (idris2Default) builtinPackages;

  overrides = callPackage ./idris2-pack-db/overrides.nix { inherit idris2 idris2Support; };

  attrsToBuildIdris =
    packageName: attrs:
    let
      execOrLib = (
        p: if attrs.ipkgJson ? "executable" then p.executable else p.library { inherit withSource; }
      );
      idrisPackageAttrs = {
        inherit (attrs) ipkgName;
        version = attrs.ipkgJson.version or "unversioned";
        src = fetchgit (attrs.src // { fetchSubmodules = false; });
        idrisLibraries = map (depName: idris2Packages.${depName}) (
          lib.subtractLists builtinPackages attrs.ipkgJson.depends
        );
        meta.packName = attrs.packName;
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
    idris2Api
    buildIdris
    buildIdris'
    idris2Packages
    experimental
    ;
}
