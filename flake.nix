{
  inputs = {
    nixpkgs.url = "github:/nixos/nixpkgs/nixpkgs-unstable";
    idris2-pack-db = {
      url = "github:/stefan-hoeck/idris2-pack-db";
      flake = false;
    };
    idris2 = {
      url = "github:/idris-lang/idris2/c5f31c9d20c50196d0a5edf13f5e1344bf38c226";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, idris2-pack-db, idris2 }:
  let inherit (nixpkgs) lib;
      forEachSystem = lib.genAttrs lib.systems.flakeExposed;
      ps = forEachSystem (system: import ./. { pkgs = import nixpkgs { inherit system; }; idris2Override = idris2.packages.${system}.idris2; buildIdrisOverride = idris2.buildIdris.${system}; });
  in
  {
    packages = lib.mapAttrs (n: attrs: attrs.packages) ps;
  };
}
