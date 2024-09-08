{
  inputs = {
    nixpkgs.url = "github:/nixos/nixpkgs/nixpkgs-unstable";
    idris2PackDbSrc = {
      url = "github:/stefan-hoeck/idris2-pack-db";
      flake = false;
    };
    idris2 = {
      url = "github:/idris-lang/idris2/5459e1726582c7326c3846bd98dfaeb9ac25cdfc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    idris2Lsp = {
      url = "github:/idris-community/idris2-lsp/971937339fa1650339e14098f73a39052fb9d7f0";
      inputs.idris.follows = "idris2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      idris2,
      idris2Lsp,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = lib.genAttrs lib.systems.flakeExposed;
      ps = forEachSystem (
        system:
        import ./. {
          pkgs = import nixpkgs { inherit system; };
          idris2Override = idris2.packages.${system}.idris2;
          idris2LspOverride = idris2Lsp.packages.${system}.idris2Lsp;
          buildIdrisOverride = idris2.buildIdris.${system};
          inherit system;
        }
      );
    in
    {
      packages = lib.mapAttrs (
        n: attrs: (attrs.idris2Packages // { inherit (attrs) idris2 idris2Lsp; })
      ) ps;
      idris2Packages = lib.mapAttrs (n: attrs: attrs.idris2Packages) ps;
      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
