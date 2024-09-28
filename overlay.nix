# Provide an overlay that overrides the nixpkgs versions of the idris2 tools
# with the versions exposed from this flake.
{
  idris2,
  idris2Lsp,
  withSource,
}:
final: prev:
let
  packages = import ./default.nix {
    inherit (prev) system;
    inherit withSource;
    pkgs = prev;
    idris2Override = idris2.packages.${prev.system}.idris2;
    idris2SupportOverride = idris2.packages.${prev.system}.support;
    idris2LspOverride = idris2Lsp.packages.${prev.system}.idris2Lsp;
    buildIdrisOverride = idris2.buildIdris.${prev.system};
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
    packdb = packages.idris2Packages;
  };
  idris2 = final.idris2Packages.idris2;
}
