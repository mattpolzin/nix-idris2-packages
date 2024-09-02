This is an experimental stab at populating Nix derivations for all the same packages as Pack currently offers.

## Updating
To update to the latest package set & package versions Pack has to offer, run the `update.sh` script from the root of the repository. You must run this with a version of Idris2 in your `PATH` that supports the `--dump-ipkg-json` command. That's important because the version of Idris2 published in Nixpkgs as of 2024/09/01 is not new enough to include that command.
