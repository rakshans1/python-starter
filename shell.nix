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
  '';

in mkShell {
  buildInputs = inputs;
  shellHook = hooks;

  LOCALE_ARCHIVE = if pkgs.stdenv.isLinux then "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
}
