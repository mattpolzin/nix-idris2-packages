This is an experimental stab at populating Nix derivations for all the same
packages as Pack currently offers.

In addition to the brief instructions given below, you can find example
projects that use this packageset in the `examples/` folder.

## Using in your project
You can use this packageset in your Flake-based project, your non-Flake project,
or a developer shell.

Cachix is currently only populated for the non-Flake usecase but its quite
optional to take advantage of the binary cache anyway. To use the cachix build
cache, add `"https://gh-nix-idris2-packages.cachix.org"` to your list of
substituters and
`"gh-nix-idris2-packages.cachix.org-1:iOqSB5DrESFT+3A1iNzErgB68IDG8BrHLbLkhztOXfo="`
to your list of trusted-public-keys.

### Getting the package set
You can use this package set as either a flake input or imported from a
derivation.

#### Flake project
_Todo_

#### Non-Flake project
A non-flake project can import the Idris2 package set pinned at a particular
revision as in the following snippet.
```nix
let
  packageset = import (pkgs.fetchgit {
    url = "https://github.com/mattpolzin/nix-idris2-packages";
    rev = "245a47d5f86aa74c4aa423dc448488e26507e114";
    hash = "sha256-QAtztZ30wxrx8XAFO5UbxpLr+hyLD+UwdQn9+AKitKY=";
  }) {};
in
{}
```

### Building a project
Once you've got the package set, whether as a flake or not, you can use the
`buildIdris` function. You get back a package set with options to build your
package as either a library or an executable. If you are building a library, you
can choose to include the source code or not (including the source code is
helpful for editor integrations when developing against the library). Here's a
snippet illustrating building a library with source code included:
```nix
let myPkg = packageset.buildIdris {
  ipkgName = "my-pkg";
  src = ./.;
  idrisLibraries = [];
};
in myPkg.library { withSource = true; }
```

The three arguments shown above are required. Note that the `ipkgName` is the
exact name of the ipkg file _without_ a file extension. You can pass
`buildIdris` any other arguments supported by `mkDerivation` as well. Commonly
this may include passing a C library required at runtime to the `buildInputs`.

If you'd like to build an executable, replace `myPkg.library {...}` with
`myPkg.executable`. If you'd like to build a library and not include the source
code, you can omit the `withSource` argument which will default to `false`:
`myPkg.library {}`.

If your package depends on other Idris2 packages, build them with `buildIdris`
and pass them in the `idrisLibraries` list. If you need to use other packages
that are already a part of the package set, you can include them even more
readily; for example, including the `ncurses-idris` library looks like:
`idrisLibraries = [ packageset.idris2Packages.ncurses-idris ]`.

### Using a developer Shell
You can easily set a dev shell up with the Nixpkgs `mkShell` function. Pass it
any executables you want to use in your dev shell under the `packages` argument
and pass it your project's `library {}` or `executable` under the `inputsFrom`
argument.
```nix
let
  inherit (packageset) idris2 idris2Lsp;
  myPkg = import ./my-pkg.nix;
in
pkgs.mkShell {
  packages = [
    idris2
    idris2Lsp
  ];

  inputsFrom = [
    myPkg.executable
  ];
}
```

## Updating this packageset
To update to the package set & package versions to the latest Pack has to offer,
run the `update.sh` script from the root of the repository. You must run this
with a version of Idris2 in your `PATH` that supports the `--dump-ipkg-json`
command. That's important because the version of Idris2 published in Nixpkgs as
of 2024/09/01 is not new enough to include that command.

## Adding new packages
To add new packages to this packageset, please add them to Pack's [package database](https://github.com/stefan-hoeck/idris2-pack-db).
New packages in Pack's database will automatically be pulled into this Nix
packageset each night.
