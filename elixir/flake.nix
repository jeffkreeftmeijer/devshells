{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/69ee1d82f1fa4c70a3dc9a64111e7eef3b8e4527";
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
            elixir
          ];
        };
      }
    );
}
