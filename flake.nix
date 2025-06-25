{
  # NOTE: This file | Flake is needes to those users who uses NixOS | Nix package manager with flake feature
  # enabled.
  # This doesn't concern you if you are not using NixOS | Nix package manager

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

          # NOTE: Init of zsh removes the virtual environment,
          # commenting out zsh until an solution is found
          shellHook = ''
            # exec zsh
            echo "Python : $(python --version)"
            if [ -d 'venv' ]; then
              # Activate the virtual environment
              source venv/bin/activate
            else
              # Create virtual environment if not found and activate the virtual environment
              python -m venv venv
              # TODO: install requirements through pip is requirement.txt is found in the directory
              source venv/bin/activate
            fi
          '';
        };
      }
    );
}
