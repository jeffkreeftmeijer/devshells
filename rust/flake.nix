{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/92d295f588631b0db2da509f381b4fb1e74173c5";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = with pkgs; mkShell {
          buildInputs = [
            darwin.apple_sdk.frameworks.SystemConfiguration
            libiconv
            gcc
            cargo
            rustc
            rustfmt
            rustPackages.clippy
            rust-analyzer
          ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
        };
      }
    );
}
