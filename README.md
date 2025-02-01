
**NOTE** If you are coming here because you've noticed breaking changes
introduced on 2025-01-26, see the [CHANGELOG](./CHANGELOG.md).

---

This repository contains Nix derivations for all the same packages as Pack
currently offers.

In addition to the brief instructions given below, you can find example projects
that use this packageset in the `examples/` folder.

## What is it?
This is a Nix wrapper around the Idris2 Pack package database. What that means
is that it makes it easy to use the packages found in that database within a Nix
derivation that builds your own Idris2 package. This project doesn't facilitate
using Pack itself, it provides packages wrapped in `buildIdris` Nix derivations
that can be used in your own `buildIdris` call by passing them as the
`idrisLibraries` argument.

The `buildIdris` function offered by this package set is the same one you may be
familiar with from the Nix tooling in the Idris2 compiler repo or the Nixpkgs
`idris2Packages.buildIdris`. This project additionally offers a `buildIdris'`
function that uses `ipkg` data to fill in additional information. See the
section on `buildIdris'` below for details.

See also the [Alternatives](#alternatives) section.

## Releases
This project is updated nightly with a new commit and I generally recommend
using the latest commit of HEAD as your target.

I _will_ cut releases on rare occasions to indicate and describe significant
and/or breaking changes to the project, but releases will not be intended to
reflect the versions of the packages in the packageset.

See the [CHANGELOG](./CHANGELOG.md).

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
A flake project can use the Idris2 package set as an input. If you want to
benefit from the Cachix cache at all (currently only caches the compiler & LSP,
but that's quite a bit of time saved), you'll need to avoid changing the
`follows` for the package set.

You can use the basic template as a starting place with `nix flake init -t
github:mattpolzin/nix-idris2-packages` or use similar code to the following:
```nix
inputs.packageset.url = "github:mattpolzin/nix-idris2-packages";

outputs = { packageset, ...}:
  let
    inherit (packageset.packages.x86_64-linux) idris2 idris2Lsp idris2Packages
    buildIdris buildIdris';
  in
  {}
```

If you're setting up a developer shell or have some other need for source code
of your dependencies, you can use any given package's `withSource` passthru
attribute to get a package ready for use in a development environment. For
example:
```
mkShell {
  packages = [ idris2 idris2Lsp ];
  inputsFrom = [ myPkg.withSource ];
}
```

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

  inherit (packageset) idris2 idris2Lsp idris2Packages buildIdris buildIdris';
in
{}
```

If you're setting up a developer shell or have some other need for source code
of your dependencies, see the note at the end of the Flake project section just
above.

### Building a project
Once you've got the package set, whether as a flake or not, you can use the
`buildIdris` function (or see below for the even more convenient `buildIdris'`
function). You get back an attribute set with options to build your package as
either a library or an executable. If you are building a library, you can choose
to include the source code or not (including the source code is helpful for
editor integrations when developing against the library). Here's a snippet
illustrating building a library without source code included:
```nix
let myPkg = packageset.buildIdris {
  ipkgName = "my-pkg";
  src = ./.;
  idrisLibraries = [];
};
in myPkg.library'
```

The three arguments shown above are required. Note that the `ipkgName` is the
exact name of the ipkg file _without_ a file extension. You can pass
`buildIdris` any other arguments supported by `mkDerivation` as well. Commonly
this may include passing a C library required at runtime to the `buildInputs`.

If you'd like to build an executable, replace `myPkg.library'` with
`myPkg.executable`.

If your package depends on other Idris2 packages, build them with `buildIdris`
and pass them in the `idrisLibraries` list. If you need to use other packages
that are already a part of the package set, you can include them even more
readily; for example, including the `ncurses-idris` library looks like:
`idrisLibraries = [ packageset.idris2Packages.packdb.ncurses-idris ]`.

If you'd like to build your package without source and then later specify source should be included in a developer shell, you can:
```nix
let
  mypkg = buildIdris { ... };
in
rec {
  lib = mypkg.library';
  libWithSrc = lib.withSource;
}
```

#### The buildIdris' function
In addition to surfacing the `buildIdris` function, this project supports
`buildIdris'`. The latter will attempt to do the following:
  - Determine the package version from the `ipkg` file.
  - Automatically add any dependencies that can be found in this package set to
    the `idrisLibraries` of `buildIdris`.
  - Determine if this package is an executable or library based on whether the
    `ipkg` file has an `executable` property and call the appropriate
    `.executable` or `.library'` attributes of the `buildIdris` result.

This means you probably don't want to set `idrisLibraries` yourself or you will
overwrite the libraries `buildIdris'` finds in the package set, but if you need
to add additional libraries (perhaps not all dependencies are found in the
package set) you can still do that with the `extraIdrisLibaries` argument to
`buildIdris'`.

See `examples/non-flake-build-idris-prime/` for an example using this
convenience function.

### Using a developer Shell
You can easily set a dev shell up with the Nixpkgs `mkShell` function. Pass it
any executables you want to use in your dev shell under the `packages` argument
and pass it your project's `library` or `executable` under the `inputsFrom`
argument. It is recommended to include source code when setting up a developer
environment. You do this with the `withSource` passthru attribute as seen below.
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
    myPkg.executable.withSource
  ];
}
```

#### No-fuss developer shell
If you are going to work on an Idris2 package for which no shell.nix file exists
ahead of time, there is a flake-based command you can run to get `idris2` and
`idris2-lsp` set up for a project in the current directory along with all
dependencies built and available. The following only works trivially if there is
exactly one `ipkg` file in the current directory. Note that this function
currently relies on the `PWD` environment variable and is known to not work on
some systems (improvement PRs welcome).

```shell
nix develop --impure --expr '(builtins.getFlake "github:mattpolzin/nix-idris2-packages").impureShell'
```

It's a bit of a mouthful, but that'll spin up a new developer shell. If you do
want or need to specify an ipkg file explicitly, you can pass `ipkgName` which
must be the name of the ipkg file without its extension. It can, however, point
to an ipkg file in a subdirectory. For example:
```shell
nix develop --impure --expr '(...).impureShell { ipkgName = "subdir/my-pkg"; }'
```

Although you do need the flakes experimental feature enabled either way, you can
run the shell with `nix-shell` if you prefer:

```shell
nix-shell --expr '(builtins.getFlake "github:mattpolzin/nix-idris2-packages").impureShell'
```

## Experimental stuff
This packageset might from time to time experiment with new (almost exclusively
backwards compatible) interfaces to existing functions or derivations surfaced
originally by nixpkgs, idris2, or this packageset.

There are not currently any differences in the experimental packageset (no
current experiments).

## Updating this packageset
To update to the package set & package versions to the latest Pack has to offer,
run the `update.sh` script from the root of the repository.

the package set is updated automatically by CI each night. 

## Adding new packages
To add new packages to this packageset, please add them to Pack's [package
database](https://github.com/stefan-hoeck/idris2-pack-db). New packages in
Pack's database will automatically be pulled into this Nix packageset each
night.

If the new package requires any special Nix setup, you may need to add an entry
to the `idris2-pack-db/overrides.nix` file as well.

## Alternatives
This is not necessarily a comprehensive list of alternatives. Please open an
issue or a PR if you'd like me to cover an alternative that isn't mentioned here
yet.

### [`claymager/idris2-pkgs`](https://github.com/claymager/idris2-pkgs)
This is (as far as I am aware) the first really robust implementation of Idris2
package management via Nix. There are far more similarities than differences
between `idris2-pkgs` and `nix-idris2-packages`. The biggest two differences I
believe are: 
  1. `idris2-pkgs` has fallen out of maintenance (though that's not to say it is
     necessarily a bad choice)
  2. `nix-idris2-packages` always offers the same packages as `pack` whereas
     `idris2-pkgs` maintains its own list of packages.

### [`thatonelutenist/idr2nix`](https://sr.ht/~thatonelutenist/idr2nix)
I am not intimately familiar with this project, but there is a clear difference
in methodology that is worth speaking to.

`nix-idris2-packages` (this project) centers around a `buildIdris` Nix function
that reads an `ipkg` file, resolves dependencies, etc. at evaluation time
without creating an additional Nix file. This is similar in feel to using other
"build"/"make" functions in the Nix ecosystem like `buildNpmPackage`.

`idr2nix` is a standalone application that generates a Nix derivation based on
an Idris2 project. This is similar in feel to using other "2nix" tools in the
Nix ecosystem like `npm2nix`.

One tradeoff here is that `buildIdris` is going to take longer to evaluate but
`idr2nix` is going to require a generated Nix file be stored and updated as the
project changes.
