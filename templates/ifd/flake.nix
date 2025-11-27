{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    packageset.url = "github:mattpolzin/nix-idris2-packages";
    # ^ don't set any follows for packageset if you want to benefit from the
    # Cachix cache. otherwise, go ahead.
  };

  outputs =
    {
      self,
      nixpkgs,
      packageset,
      ...
    }:
    let
      lib = nixpkgs.lib;
      forEachSystem =
        f:
        lib.genAttrs lib.systems.flakeExposed (
          system:
          f {
            inherit system;
            inherit (packageset.packages.${system}) idris2 idris2Lsp buildIdris' idris2Packages;
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      packages = forEachSystem (
        { buildIdris', ... }:
        let
          # `buildIdris'` requires 'allow-import-from-derivation' set true
          # and it takes a bit longer to evaluate than `buildIdris` does but in
          # return you don't need to specify `idrisLibraries` yourself if all
          # libraries can be found in pack's packageset.
          myPkg = buildIdris' {
            ipkgName = "my-pkg";
            src = ./.;
            extraIdrisLibraries = [
              # specify libraries here if you needed to build them yourself
              # because they are not found in the packageset.
            ];
          };
        in
        {
          default = myPkg.executable; # or myPkg.library'
        }
      );

      devShells = forEachSystem (
        {
          system,
          pkgs,
          idris2,
          idris2Lsp,
          ...
        }:
        {
          default = pkgs.mkShell {
            packages = [
              idris2
              idris2Lsp
            ];
            inputsFrom = [ self.packages.${system}.default.withSource ];
          };
        }
      );
    };

  nixConfig = {
    extra-substituters = [
      "https://gh-nix-idris2-packages.cachix.org"
    ];
    allow-import-from-derivation = true;
  };
}
