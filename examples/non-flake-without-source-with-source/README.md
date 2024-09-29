
This example is like the original non-flake example but it uses the feature that
allows you to take a library built without source and use it with source later.

Build the example with `nix-build`. Run the example with
`$(nix-build)/bin/my-pkg`. Start a development shell including `idris2` and
`idris2-lsp` with `nix-shell`.
