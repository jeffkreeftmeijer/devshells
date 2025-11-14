{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/7cc0bff31a3a705d3ac4fdceb030a17239412210";
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
            elixir-ls
          ];
        };
      }
    );
}
