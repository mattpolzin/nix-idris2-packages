{
  inputs = {
    nixpkgs.url = "github:/nixos/nixpkgs/nixpkgs-unstable";
    idris2PackDbSrc = {
      url = "github:/stefan-hoeck/idris2-pack-db";
      flake = false;
    };
    idris2 = {
      url = "github:/idris-lang/idris2/826b7eb3ecbc8ca2904b6e01a700452af603f1bc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    idris2Lsp = {
      url = "github:/idris-community/idris2-lsp/e2c4c53997ce1f37b72d9516fd4baeb66740284e";
      inputs.idris.follows = "idris2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      idris2,
      idris2Lsp,
      self,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = lib.genAttrs lib.systems.flakeExposed;
      ps =
        withSource:
        forEachSystem (
          system:
          import ./. {
            pkgs = import nixpkgs { inherit system; };
            idris2Override = idris2.packages.${system}.idris2;
            idris2SupportOverride = idris2.packages.${system}.support;
            idris2LspOverride = idris2Lsp.packages.${system}.idris2Lsp;
            buildIdrisOverride = idris2.buildIdris.${system};
            inherit system withSource;
          }
        );
    in
    {
      overlays =
        let
          mkOverlay = withSource: import ./overlay.nix { inherit idris2 idris2Lsp withSource; };
        in
        {
          withoutSource = mkOverlay false;
          withSource = mkOverlay true;
          default = self.overlays.withSource;
        };

      packages = lib.mapAttrs (
        n: attrs:
        (
          attrs.idris2Packages
          // {
            inherit (attrs)
              idris2
              idris2Lsp
              idris2Api
              ;
          }
        )
      ) (ps false);
      idris2Packages = lib.mapAttrs (n: attrs: attrs.idris2Packages) (ps false);
      idris2PackagesWithSource = lib.mapAttrs (n: attrs: attrs.idris2Packages) (ps true);

      buildIdris = lib.mapAttrs (_: attrs: attrs.buildIdris) (ps false);
      buildIdris' = lib.mapAttrs (_: attrs: attrs.buildIdris') (ps false);
      experimental = lib.mapAttrs (_: attrs: attrs.experimental) (ps false);

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      templates = {
        default = {
          path = ./templates/basic;
          description = "A simple template that produces results for multiple systems without using flake-utils";
        };
      };

      impureShell =
        {
          system ? builtins.currentSystem,
          src ? /. + builtins.getEnv "PWD",
          ipkgName ?
            let
              fileMatches = lib.filesystem.locateDominatingFile "(.*)\.ipkg" src;
            in
            if fileMatches == null then
              throw "Could not locate an ipkg file automatically"
            else
              let
                inherit (fileMatches) matches path;
                relative = lib.head (lib.head matches);
                absolute = lib.path.append path relative;
              in
              lib.strings.removePrefix ((toString src) + "/") (toString absolute),
        }:
        nixpkgs.legacyPackages.${system}.callPackage ./ipkg-shell.nix {
          inherit src ipkgName;
          inherit ((ps true).${system}) buildIdris' idris2 idris2Lsp;
        };
    };
}
