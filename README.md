This is an experimental stab at populating Nix derivations for all the same packages as Pack currently offers.

## Using in your project
You can use this packageset in your Flake-based project, your non-Flake project, or a developer shell.

In any case, to take advantage of the cachix build cache, add `"gh-harmony.cachix.org"` to your list of substituters and `"gh-nix-idris2-packages.cachix.org-1:iOqSB5DrESFT+3A1iNzErgB68IDG8BrHLbLkhztOXfo="` to your list of trusted-public-keys.

### Flake project

### Non-Flake project

### Developer Shell

## Updating this packgeset
To update to the latest package set & package versions Pack has to offer, run the `update.sh` script from the root of the repository. You must run this with a version of Idris2 in your `PATH` that supports the `--dump-ipkg-json` command. That's important because the version of Idris2 published in Nixpkgs as of 2024/09/01 is not new enough to include that command.
