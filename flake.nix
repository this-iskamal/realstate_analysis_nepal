{
  # NOTE: This file | Flake is needes to those users who uses NixOS | Nix package manager with flake feature
  # enabled.
  # This doesn't concern you if you are not using NixOS | Nix package manager

  description = "Python Development Environement";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... } :
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs { inherit system;};
        python = pkgs.python312;
        pythonPackages = pkgs.python312Packages;

        required_pythonPackages = with pythonPackages; [ polars numpy matplotlib seaborn];

      in {
        devShells.default = pkgs.mkShell {
          packages = [
            python
          ] ++ required_pythonPackages;

          # NOTE: Init of zsh removes the virtual environment,
          # commenting out zsh until an solution is found
          # Read for adding python packages that depend on other libraries:
          # https://stackoverflow.com/questions/59594317/how-can-i-add-a-python-package-to-a-shell-nix-if-its-not-in-nixpkgs
          shellHook = ''
            echo "Entering Nix DevShell with Python: $(python --version) Virtual Environement"
            echo "Python : $(python --version)"
            export PATH="${python}/bin:$PATH"
            
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
