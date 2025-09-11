#! /usr/bin/env nix
#! nix shell nixpkgs#nixVersions.nix_2_30 nixpkgs#jq nixpkgs#nodejs nixpkgs#nix-prefetch-git nixpkgs#gnused --command bash

function header() {
  echo "-------- $1 --------"
}

function debug() {
  echo "[DEBUG] $1"
}

set -euxo pipefail

nix flake update nixpkgs
nix flake update idris2PackDbSrc

header "Updating Pack Collection"

pack_db_location=$(nix-build --expr 'with import <nixpkgs> {}; callPackage ./idris2-pack-db/unresolved-pack-db.nix {}')

debug "pack-db latest dataset at $pack_db_location"

header "Updating Idris2 Pin"

cat $pack_db_location/share/idris2.json \
  | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/idris2.json

sed -i'' \
  "s#idris-lang/idris2/.*\";#idris-lang/idris2/$(cat ./idris2-pack-db/idris2.json | jq -r .src.rev)\";#" \
  ./flake.nix
rm ./idris2-pack-db/idris2.json

nix flake update idris2

header "Updating Idris2LSP Pin"

cat $pack_db_location/share/idris2-lsp.json \
  | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/idris2-lsp.json

sed -i'' \
  "s#idris-community/idris2-lsp/.*\";#idris-community/idris2-lsp/$(cat ./idris2-pack-db/idris2-lsp.json | jq -r .src.rev)\";#" \
  ./flake.nix
rm ./idris2-pack-db/idris2-lsp.json

nix flake update idris2Lsp

header "Updating Package Pins"

nix shell .#idris2 --command bash -c "cat $pack_db_location/share/packages.json | node ./idris2-pack-db/update-hashes.js > ./idris2-pack-db/pack-db-resolved.json.new"
cat ./idris2-pack-db/pack-db-resolved.json.new \
  | jq 'map_values(del(.ipkgJson.modules))' > ./idris2-pack-db/pack-db-resolved.json
rm ./idris2-pack-db/pack-db-resolved.json.new
