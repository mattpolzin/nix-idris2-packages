{
  mkShell,
  buildIdris',
  idris2,
  idris2Lsp,
  src,
  ipkgName,
}:
let
  pkg = buildIdris' {
    inherit src ipkgName;
  };
in
mkShell {
  packages = [
    idris2
    idris2Lsp
  ];
  inputsFrom = [ pkg ];
}
