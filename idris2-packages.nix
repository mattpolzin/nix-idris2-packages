{
  lib,
  fetchgit,
  idris2Packages,
}:
let attrsToBuildIdris = packageName: attrs:
  idris2Packages.buildIdris {
    inherit (attrs) ipkgName;
    src = fetchgit (attrs.src // {deepClone = true;});
    idrisLibraries = [];
  };

  pack-db-json = builtins.fromJSON (builtins.readFile ./idris2-pack-db/pack-db-resolved.json);
  packages = lib.mapAttrs attrsToBuildIdris pack-db-json;
in packages

# fetchgit {
#   url = "https://github.com/mattpolzin/idris-indexed";
#   rev = "d3fe9a1d1aac2e269667e9d2bb44eac8bee6a013";
#   hash = "sha256-A9p5rjjy7+8jdExd4PgxJDYWdQrYbqpqI1XuB0SI/Sk=";
# }
