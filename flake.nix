{
  description = "Python Starter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        inherit (pkgs) inotify-tools terminal-notifier;
        inherit (pkgs.lib) optionals;
        inherit (pkgs.stdenv) isDarwin isLinux;

        linuxDeps = optionals isLinux [ inotify-tools ];
        darwinDeps = optionals isDarwin [ terminal-notifier ];
      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                python314
                uv
              ]
              ++ linuxDeps
              ++ darwinDeps;
            shellHook = ''
              export LANG=C.UTF-8
            '';
          };
        };
      }
    );
}
