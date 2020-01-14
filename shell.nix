{ nixpkgs ? import ./.nix/pinned-nixpkgs.nix {} }:

let

package = nixpkgs.callPackage ./. {
  inherit nixpkgs;
  fromNixShell = true;
};

in

nixpkgs.mkShell {
  inputsFrom = [ package ];

  preShellHook = ''
    ${package.preShellHook}

    # Bring xdg data dirs of dependencies and current program into the
    # environement. This will allow us to get shell completion if any
    # and there might be other benefits as well.
    xdg_inputs=( "${package}" "''${buildInputs[@]}" )
    for p in "''${xdg_inputs[@]}"; do
      1>&2 ls -la "$p"
      1>&2 echo "p: $p"
      exit 1
      if [[ -d "$p/share" ]]; then
        XDG_DATA_DIRS="''${XDG_DATA_DIRS}''${XDG_DATA_DIRS+:}$p/share"
      fi
    done
    export XDG_DATA_DIRS
  '';
}


