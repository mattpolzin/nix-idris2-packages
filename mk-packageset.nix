let
  packDb = import ./idris2-pack-db/pack-db.nix;
in
{
  lib,
  fetchgit,
  buildIdris,
  builtinPackages,
  overrides,
  withSource,
  idris2Packages,
  idris2Api,
  idris2Lsp,
}:
let
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

in
(lib.mapAttrs attrsToBuildIdris packDb)
// {
  # The idris2-api package is named 'idris2':
  idris2 = idris2Api;
  # We build the LSP from its own repo's derivation:
  idris2-lsp = idris2Lsp;
}
