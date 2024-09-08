let
  flakeLock = builtins.fromJSON (builtins.readFile ../flake.lock);
  packDbRev = flakeLock.nodes.idris2PackDbSrc.locked.rev;
  packDbHash = flakeLock.nodes.idris2PackDbSrc.locked.narHash;
in
{
  fetchFromGitHub,
  stdenvNoCC,
  yq,
  idris2PackDbSrc ? fetchFromGitHub {
    owner = "stefan-hoeck";
    repo = "idris2-pack-db";
    rev = packDbRev;
    hash = packDbHash;
  },
}:
stdenvNoCC.mkDerivation {
  name = "idris2-pack-db";

  src = idris2PackDbSrc;

  nativeBuildInputs = [
    yq
  ];

  buildPhase = ''
    file=$(ls -t ./collections | grep 'nightly-.*' | tail -1)
    echo "Latest collections manifest: $file"
    mkdir -p $out/share
    cat ./collections/$file \
      | tomlq .db > $out/share/packages.json
    cat ./collections/$file \
      | tomlq .idris2 > $out/share/idris2.json
  '';
}
