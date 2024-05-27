{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/3281bec7174f679eabf584591e75979a258d8c40";
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
            cargo
            git
            which
            openssl
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.SystemConfiguration
            libiconv
            curl
            snappy
            cmake
            protobuf
            libbson
          ];

          nativeBuildInputs = [
            pkg-config
          ];
        };
      }
    );
}
