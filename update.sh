#! /usr/bin/env nix
#! nix shell nixpkgs#nodejs nixpkgs#nix-prefetch-git nixpkgs#gnused --command bash

set -euxo pipefail

nix flake update nixpkgs
nix flake update idris2PackDbSrc

pack_db_location=$(nix-build --expr 'with import <nixpkgs> {}; callPackage ./idris2-pack-db {}')

echo "pack-db latest dataset at $pack_db_location"

cat $pack_db_location/share/idris2.json \
  | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/idris2.json

sed -i'' \
  "s#idris-lang/idris2/.*\";#idris-lang/idris2/$(cat ./idris2-pack-db/idris2.json | jq -r .src.rev)\";#" \
  ./flake.nix

nix flake update idris2

nix shell .#idris2 --command bash -c "cat $pack_db_location/share/packages.json | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/pack-db-resolved.json"
