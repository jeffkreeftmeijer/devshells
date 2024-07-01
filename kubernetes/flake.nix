{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/9c513fc6fb75142f6aec6b7545cb8af2236b80f5";
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
            minikube
            kubectl
            kubernetes-helm
          ];
        };
      }
    );
}
