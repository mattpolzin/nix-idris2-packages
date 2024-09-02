{
  fetchFromGitHub,
  stdenvNoCC,
  yq,
}:
stdenvNoCC.mkDerivation {
  name = "idris2-pack-db";

  src = fetchFromGitHub {
    owner = "stefan-hoeck";
    repo = "idris2-pack-db";
    rev = "98fd629a28d720cdada61b4e4baac37f9207843c";
    hash = "sha256-dBX+mP0cZyCOQj0CylnBuwSnBbUGhUTM9ZJv63yyLe8=";

    sparseCheckout = [
      "collections"
    ];
  };

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
