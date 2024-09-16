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
  pkg-config,
  makeWrapper,
  zsh,
  idris2Support,
  idris2,
  chez,
  go,
  gsl,
  libuv,
  libxcrypt,
  ncurses5,
  rtl-sdr-librtlsdr,
  sqlite,
}:
{
  base64 = {
    meta.broken = stdenv.isAarch64 || stdenv.isAarch32;
  };

  cheerio = {
    preInstall = ''
      mv ./cheerio/build ./
    '';
    # would need to figure out pnpm dependencies to fix.
    # for now, it will build ok but cannot be executed.
    meta.broken = true;
  };

  cptr = {
    patches = [
      ../cptr.patch
    ];

    preBuild = ''
      patchShebangs --build gencode.sh
    '';
  };

  crypt = {
    buildInputs = [
      libxcrypt
    ];
  };

  epoll = {
    meta.platforms = lib.platforms.linux;
  };

  idris2-go = {
    nativeBuildInputs = [
      makeWrapper
    ] ++ lib.optional stdenv.isDarwin zsh;

    buildInputs = [
      go
    ];

    postInstall =
    let
        name = "${idris2.pname}-${idris2.version}";
        globalLibraries = [
          "\\$HOME/.nix-profile/lib/${name}"
          "/run/current-system/sw/lib/${name}"
          "${idris2}/${name}"
        ];
        globalLibrariesPath = builtins.concatStringsSep ":" globalLibraries;
        supportLibrariesPath = lib.makeLibraryPath [ idris2Support ];
        supportSharePath = lib.makeSearchPath "share" [ idris2Support ];
    in ''
      wrapProgram "$out/bin/idris2-go" \
        --set-default CHEZ "${lib.getExe chez}" \
        --run 'export IDRIS2_PREFIX=''${IDRIS2_PREFIX-"$HOME/.idris2"}' \
        --suffix IDRIS2_LIBS ':' "${supportLibrariesPath}" \
        --suffix IDRIS2_DATA ':' "${supportSharePath}" \
        --suffix IDRIS2_PACKAGE_PATH ':' "${globalLibrariesPath}" \
        --suffix LD_LIBRARY_PATH ':' "${supportLibrariesPath}" \
        --suffix DYLD_LIBRARY_PATH ':' "${supportLibrariesPath}" \
        --set-default IDRIS2_GO ${lib.getExe go}
    '';
  };

  distribution = {
    buildInputs = [
      gsl.dev
    ];
  };

  ncurses-idris = {
    buildInputs = [
      ncurses5.dev
    ];
  };

  rtlsdr = {
    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      rtl-sdr-librtlsdr
    ];
  };

  spidr = {
    meta.platforms = lib.platforms.linux;
    # Spidr uses curl to download a library as part of installation.
    # that's not allowed in a sandboxed build environment, so fixing this
    # will mean patching the curl call out and taking care of it as a FOD
    # I suppose.
    meta.broken = true;
  };

  sqlite3 = {
    buildInputs = [
      sqlite.dev
    ];
  };

  sqlite3-rio = {
    buildInputs = [
      sqlite.dev
    ];
  };

  uv = {
    buildInputs = [
      libuv.dev
    ];
  };

  uv-data = {

    preBuild = ''
      patchShebangs --build data/gencode.sh
      patchShebangs --build data/cleanup.sh
    '';

    buildInputs = [
      libuv.dev
    ];
  };
}
