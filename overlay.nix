# Provide an overlay that supports overriding the nixpkgs versions of the
# idris2 tools.
{
  idris2 ? null,
  idris2Lsp ? null,
  withSource ? true,
}:
final: prev:
let
  inherit (final) lib;
  packages = import ./default.nix {
    inherit (prev) system;
    inherit withSource;
    pkgs = prev;
    idris2Override = lib.mapNullable (idr: idr.packages.${prev.system}.idris2) idris2;
    idris2SupportOverride = lib.mapNullable (idr: idr.packages.${prev.system}.support) idris2;
    idris2LspOverride = lib.mapNullable (lsp: lsp.packages.${prev.system}.idris2Lsp) idris2Lsp;
    buildIdrisOverride = lib.mapNullable (idr: idr.buildIdris.${prev.system}) idris2;
  };
in
{
  idris2Packages = prev.idris2Packages // {
    inherit (packages)
      buildIdris
      buildIdris'
      idris2
      idris2Api
      idris2Lsp
      ;
    inherit (packages.idris2Packages) pack packdb;
  };
  inherit (final.idris2Packages) idris2;
}
