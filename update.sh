#! /usr/bin/env nix-shell
#! nix-shell -i bash -p yq nodejs nix-prefetch-git

set -euo pipefail

pack_db_location=$(nix-build --expr 'with import <nixpkgs> {}; callPackage ./idris2-pack-db {}')

echo "pack-db latest dataset at $pack_db_location"

cat $pack_db_location \
  | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/pack-db-resolved.json

