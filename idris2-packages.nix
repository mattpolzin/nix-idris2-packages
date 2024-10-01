# NOTE: Call this with idris2 and/or buildIdris overrides if you want to build
# packages using a different version of Idris2 than the most recent Pack
# package-set specifies. This can be useful but you are on your own in
# determining that all the packages you are going to need to build will support
# the Idris2 version you are using.
{
  lib,
  newScope,
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

  idris2Scope = lib.makeScope newScope (self: {
    idris2Support =
      if idris2SupportOverride == null then idris2Default.support else idris2SupportOverride;
    idris2 = if idris2Override == null then idris2Default.idris2 else idris2Override;
    buildIdris = if buildIdrisOverride == null then idris2Default.buildIdris else buildIdrisOverride;
    idris2Api = self.callPackage ./packages/idris2-api.nix { };
    idris2Lsp = if idris2LspOverride == null then idris2LspDefault else idris2LspOverride;

    buildIdris' = self.callPackage ./build-idris-prime.nix { };
    buildIdrisAlpha = self.callPackage ./build-idris-alpha.nix {
      idris2Version = self.idris2.version;
      support = self.idris2Support;
    };

    inherit (idris2Default) builtinPackages;

    overrides = self.callPackage ./idris2-pack-db/overrides.nix { };

    idris2Packages = self.callPackage ./mk-packageset.nix { inherit withSource; };

    experimental =
      let
        idris2Packages = self.idris2Packages.override { buildIdris = self.buildIdrisAlpha; };
        buildIdris = self.buildIdrisAlpha;
      in
      {
        inherit idris2Packages buildIdris;
        buildIdris' = self.buildIdris'.override {
          inherit idris2Packages buildIdris;
        };
      };
  });
in
{
  inherit (idris2Scope)
    idris2
    idris2Lsp
    idris2Api
    buildIdris
    buildIdris'
    idris2Packages
    experimental
    ;
}
