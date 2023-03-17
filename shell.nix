{ sources ? import ./nix/sources.nix
, pkgs ? import <nixpkgs> { overlays = [ (import ./nix/niv-overlay.nix) ]; }
}:

with pkgs;
let
  inherit (lib) optional optionals;
   basePackages = [
    (import ./nix/default.nix { inherit pkgs; })
    pkgs.niv
  ];

  inputs =  basePackages ++ lib.optionals stdenv.isLinux [ inotify-tools ]
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  # define shell startup command
  hooks = ''
    export LANG=C.UTF-8

    export PATH=$(pwd -P)/.poetry/bin:$PATH
    export PATH=$(pwd -P)/bin:$PATH
    export POETRY_VERSION=1.3.2
    export POETRY_HOME=$(pwd -P)/.poetry

    # install poetry if not exists
    if [ ! -e ".poetry/bin/poetry" ];
    then
      echo "Installing poetry $POETRY_VERSION with $(which python) @ $(python --version) at $POETRY_HOME"
      rm -Rf .poetry .venv


      curl -sSL https://install.python-poetry.org | python3 -

    fi
  '';

in mkShell {
  buildInputs = inputs;
  shellHook = hooks;

  LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
}
