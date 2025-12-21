# NOTE: Call this with idris2 and/or buildIdris overrides if you want to build
# packages using a different version of Idris2 than the most recent Pack
# package-set specifies. This can be useful but you are on your own in
# determining that all the packages you are going to need to build will support
# the Idris2 version you are using.
{
  pkgs ? import ./packages/nixpkgs.nix,
  system ? builtins.currentSystem or "unknown-system",
  idris2Override ? null,
  idris2SupportOverride ? null,
  idris2LspOverride ? null,
  buildIdrisOverride ? null,
  # Call with `withSource = true` to get jump-to-definition support with editor tooling.
  withSource ? false,
}:
pkgs.callPackage ./idris2-packages.nix {
  inherit
    system
    idris2Override
    idris2SupportOverride
    idris2LspOverride
    buildIdrisOverride
    withSource
    ;
} // { nixpkgs = pkgs; }
