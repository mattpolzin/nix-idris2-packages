{
  runCommand,
  idris2,
  src,
  ipkgName,
}:
runCommand "${ipkgName}-attrs"
  {
    nativeBuildInputs = [ idris2 ];
  }
  ''
    cd "${src}"
    idris2 --dump-ipkg-json ${ipkgName}.ipkg > $out
  ''
