{
  lib,
  mkShell,
  buildIdris',
  idris2,
  idris2Lsp,
  src,
  ipkgName ?
    let
      inherit (lib.filesystem.locateDominatingFile "(.*)\.ipkg" src) matches path;
      absolute = lib.path.append path (lib.head (lib.head matches));
    in
    lib.strings.removePrefix ((toString src) + "/") (toString absolute),
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
