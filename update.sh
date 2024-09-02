#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nodejs nix-prefetch-git sed

set -euo pipefail

nix flake update nixpkgs idris2-pack-db

pack_db_location=$(nix-build --expr 'with import <nixpkgs> {}; callPackage ./idris2-pack-db {}')

echo "pack-db latest dataset at $pack_db_location"

cat $pack_db_location/share/idris2.json \
  | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/idris2.json

sed -i'' \
  "s#idris-lang/idris2/.*\";#idris-lang/idris2/$(cat ./idris2-pack-db/idris2.json | jq -r .src.rev)#" \
  ./flake.nix

nix flake update idris2

cat $pack_db_location/share/packages.json \
  | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/pack-db-resolved.json
