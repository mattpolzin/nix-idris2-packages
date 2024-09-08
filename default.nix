# NOTE: Call this with idris2 and/or buildIdris overrides if you want to build
# packages using a different version of Idris2 than the most recent Pack
# package-set specifies. This can be useful but you are on your own in
# determining that all the packages you are going to need to build will support
# the Idris2 version you are using.
{
  pkgs ? import ./nixpkgs.nix,
  system ? builtins.currentSystem or "unknown-system",
  idris2Override ? null,
  idris2LspOverride ? null,
  buildIdrisOverride ? null,
}:
pkgs.callPackage ./idris2-packages.nix {
  inherit
    system
    idris2Override
    idris2LspOverride
    buildIdrisOverride
    ;
}
