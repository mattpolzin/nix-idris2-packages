# Override any packages in the set that need customization beyond the
# `buildIdris` invocation each gets by default. Not every package needs to have
# an entry here, only those needing tweaks. Specify an attribute set here that
# will be merged with the default attribute set and passed to `buildIdris`.
# That means any attribute `buildIdris` explicitly supports can be specified
# here in addition to any attributes supported by `mkDerivation`.
{ stdenv, ncurses }:
{
  base64 = {
    meta.broken = stdenv.isAarch64 || stdenv.isAarch32;
  };
  ncurses-idris = {
    buildInputs = [
      ncurses.dev
    ];
  };
}
