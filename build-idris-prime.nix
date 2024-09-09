{
  idris2,
  idris2Packages,
  buildIdris,
  runCommand,
}:
{
  src,
  # The `ipkgName` should NOT include the "ipkg" file extension.
  ipkgName,
  # Any package requirements of the given ipkg project that can be found in the
  # package set will be automatically provided to the `idrisLibraries` argument
  # of `buildIdris`. Use `extraIdrisLibraries` to provide any dependencies that
  # are not part of the package set. `extraIdrisLibraries` accepts other
  # packages built with `buildIdris` or `buildIdris'`.
  extraIdrisLibraries ? [ ],
  # `withSource` is only relevant if the ipkg project is not an executable.
  # Building a library with source included can make IDE/editor experience
  # nicer by enabling jump to definition and documentation viewing within
  # dependencies.
  withSource ? false,
  ipkgAttrs ? builtins.fromJSON (
    builtins.readFile (
      import ./ipkg-attrs.nix {
        inherit
          runCommand
          idris2
          src
          ipkgName
          ;
      }
    )
  ),
  ...
}@attrs:
let
  depName = ipkgDep: (builtins.head (builtins.attrNames ipkgDep));
  depFromPackageset =
    depName: if (idris2Packages ? ${depName}) then [ idris2Packages.${depName} ] else [ ];
  addDep = acc: dep: acc ++ (depFromPackageset (depName dep));

  execOrLib =
    pkg: if ipkgAttrs ? "executable" then pkg.executable else pkg.library { inherit withSource; };

  allDeps = builtins.foldl' addDep extraIdrisLibraries (ipkgAttrs.depends or [ ]);

  additionalAttrs = builtins.removeAttrs attrs [
    "src"
    "ipkgName"
    "extraIdrisLibraries"
    "withSource"
    "ipkgAttrs"
  ];
in
execOrLib (
  buildIdris (
    {
      inherit src ipkgName;
      version = ipkgAttrs.version or "unversioned";
      idrisLibraries = allDeps;
    }
    // additionalAttrs
  )
)
