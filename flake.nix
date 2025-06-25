{
  description = "Python Development Environemnt";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... } :
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [ python312  geckodriver curl];

          # FIX: Init zsh at the begining or at the end?
          shellHook = ''
            echo "Python : $(python --version)"
            if [ 'venv' -d ]; then
              echo "found venv"
            else
              echo "venv not found
            exec zsh
          '';
        };
      }
    );
}
