
# Changelog

## Release 0.0.2 (2025-01-26)
The packages that come from Pack's database are now found at
`idris2Packages.packdb` instead of directly within `idris2Packages`. They are
also no longer surfaced directly on the Flake's `packages` output. This change
removes ambiguity between packages added to `idris2Packages` explicitly and by
hand and those added automatically via Pack's database.

## Release 0.0.1 (2025-01-25)
This release just tracks the end of a period of pre-release changes that were
mostly compatible but when they were incompatible the change was still made
without much documentation.

Going forward, best effort will be made to track any breaking changes to the
packageset (not the individual packages within it, though). Those breaking
changes will be documented in this CHANGELOG.md file.
