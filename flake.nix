{
  description = "Python Starter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        inherit (pkgs) inotify-tools terminal-notifier;
        inherit (pkgs.lib) optionals;
        inherit (pkgs.stdenv) isDarwin isLinux;

        linuxDeps = optionals isLinux [ inotify-tools ];
        darwinDeps = optionals isDarwin [ terminal-notifier ]
          ++ (with pkgs.darwin.apple_sdk.frameworks; optionals isDarwin [
          CoreFoundation
          CoreServices
        ]);

      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs;  [
              python312Full
              poetry
            ] ++ linuxDeps ++ darwinDeps;
            shellHook = ''
              export LANG=C.UTF-8

              export POETRY_HOME=$PWD/.poetry
            '';
          };
        };
      });
}
