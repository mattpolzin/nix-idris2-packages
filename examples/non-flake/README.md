
This simple example uses the nix idris2 packageset to pull the `ncurses-idris`
dependency into an example Idris2 project.

Build the example with `nix-build`. Run the example with
`$(nix-build)/bin/my-pkg`. Start a development shell including `idris2` and
`idris2-lsp` with `nix-shell`.
