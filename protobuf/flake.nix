{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/a9858885e197f984d92d7fe64e9fff6b2e488d40";
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
            protobuf_21
          ];
        };
      }
    );
}
