# Override any packages in the set that need customization beyond the
# `buildIdris` invocation each gets by default. Not every package needs to have
# an entry here, only those needing tweaks. Specify an attribute set here that
# will be merged with the default attribute set and passed to `buildIdris`.
# That means any attribute `buildIdris` explicitly supports can be specified
# here in addition to any attributes supported by `mkDerivation`.
#
# `idris2Packages` is a reference to the final packages of this package set.
{
  chez,
  clang,
  cmake,
  gcc,
  gmp,
  gnumake,
  go,
  gsl,
  idris2,
  idris2Support,
  lib,
  libuuid,
  libuv,
  libxcrypt,
  lld,
  makeBinaryWrapper,
  makeWrapper,
  ncurses5,
  pkg-config,
  postgresql,
  rtl-sdr-librtlsdr,
  sqlite,
  stdenv,
  zsh,
}:
{
  async-epoll = {
    meta.platforms = lib.platforms.linux;
  };

  base64 = {
    meta.broken = stdenv.isAarch64 || stdenv.isAarch32;
  };

  c-ffi = {
    nativeBuildInputs = [ gcc ];
    # this package only builds its included C library for Linux currently.
    meta.platforms = lib.platforms.linux;
  };

  cptr = {
    preBuild = ''
      patchShebangs --build gencode.sh
    '';
  };

  crypt = {
    buildInputs = [
      libxcrypt
    ];
  };

  distribution = {
    buildInputs = [
      gsl.dev
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
      in
      ''
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

  idrisGL = {
    # see WIP branch: https://github.com/mattpolzin/nix-idris2-packages/tree/unbreak-idrisGL
    meta.broken = true;
  };

  linux = {
    preBuild = ''
      patchShebangs --build gencode.sh
    '';

    preInstall = ''
      make -C support install
    '';

    meta.platforms = lib.platforms.linux;
  };

  ncurses-idris = {
    buildInputs = [
      ncurses5.dev
    ];
  };

  oracle = {
    nativeBuildInputs = [ lld ];
  };

  pack = {
    nativeBuildInputs = [ makeBinaryWrapper ];

    buildInputs = [
      gmp
      clang
      chez
      gnumake
    ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ zsh ];

    postInstall = ''
      wrapProgram $out/bin/pack \
        --suffix C_INCLUDE_PATH : ${lib.makeIncludePath [ gmp ]} \
        --suffix PATH : ${
          lib.makeBinPath (
            [
              clang
              chez
              gnumake
            ]
            ++ lib.optionals stdenv.hostPlatform.isDarwin [ zsh ]
          )
        }
    '';
  };

  pg-idris = {
    buildInputs = [ postgresql.dev postgresql.pg_config ];
  };

  posix = {
    preBuild = ''
      patchShebangs --build gencode.sh
    '';

    preInstall = ''
      make -C support install
    '';
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

  systemd = {
    postPatch = ''
      substituteInPlace support/Makefile \
        --replace-fail '-fuse-ld=lld' ""
    '';
  };

  uuid-c = {
    buildInputs = [ libuuid ];

    postPatch = ''
      substituteInPlace support/c/CMakeLists.txt \
        --replace-fail 'VERSION 4.3' 'VERSION 4.1'
    '';

    postBuild = ''
        mkdir -p ./lib
        (cd support/c && \
          ${lib.getExe cmake} . && \
          make)
        cp support/c/*.{so,dylib} ./lib
      '';

    preInstall = ''
      export UUID_NOINSTALL_SUPPORT=true
    '';

    # this package's C library does not currently build for Darwin
    meta.platforms = lib.platforms.linux;
  };

  uv = {
    buildInputs = [
      libuv.dev
    ];
  };

  uv-data = {
    preBuild = ''
      export CC=clang

      patchShebangs --build gencode.sh
      patchShebangs --build cleanup.sh
    '';

    buildInputs = [
      clang
      libuv.dev
    ];
  };

  web-server-racket-hello-world = {
    meta.broken = true;
  };
}
