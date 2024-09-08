# Override any packages in the set that need customization beyond the
# `buildIdris` invocation each gets by default. Not every package needs to have
# an entry here, only those needing tweaks. Specify an attribute set here that
# will be merged with the default attribute set and passed to `buildIdris`.
# That means any attribute `buildIdris` explicitly supports can be specified
# here in addition to any attributes supported by `mkDerivation`.
#
# `idris2Packages` is a reference to the final packages of this package set.
{
  lib,
  stdenv,
  idris2,
  idris2Packages,
  idris2Support,
  makeWrapper,
  libxcrypt,
  libuv,
  ncurses,
}:
{
  base64 = {
    meta.broken = stdenv.isAarch64 || stdenv.isAarch32;
  };

  crypt = {
    buildInputs = [
      libxcrypt
    ];
  };

  idris2-lsp =
    let
      supportLibrariesPath = lib.makeLibraryPath [ idris2Support ];
      supportSharePath = lib.makeSearchPath "share" [ idris2Support ];

      globalLibraries =
        let
          idrName = "idris2-${idris2.version}";
        in
        [
          "\\$HOME/.nix-profile/lib/${idrName}"
          "/run/current-system/sw/lib/${idrName}"
          "${idris2}/${idrName}"
        ];
      globalLibrariesPath = builtins.concatStringsSep ":" globalLibraries;

    in
    {
      idrisLibraries = [
        idris2Packages.idris2
        idris2Packages.lsp-lib
      ];

      nativeBuildInputs = [ makeWrapper ];
      postInstall = ''
        wrapProgram $out/bin/idris2-lsp \
          --run 'export IDRIS2_PREFIX=''${IDRIS2_PREFIX-"$HOME/.idris2"}' \
          --suffix IDRIS2_LIBS ':' "${supportLibrariesPath}" \
          --suffix IDRIS2_DATA ':' "${supportSharePath}" \
          --suffix IDRIS2_PACKAGE_PATH ':' "${globalLibrariesPath}"
      '';
    };

  ncurses-idris = {
    buildInputs = [
      ncurses.dev
    ];
  };

  uv = {
    buildInputs = [
      libuv.dev
    ];
  };

  uv-data = {
    buildInputs = [
      libuv.dev
    ];
  };
}
