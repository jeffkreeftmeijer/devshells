{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/5fd8536a9a5932d4ae8de52b7dc08d92041237fc";
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
            ruby_3_3
          ];
        };
      }
    );
}
