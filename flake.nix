{
  description = "Centralized Development Shell Modules for Kungle Infrastructure";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs: {
    # Reusable atomic devenv modules
    devenvModules = {
      # OpenTofu tools
      opentofu = { pkgs, ... }: {
        packages = with pkgs; [
          tenv
          tflint
          tfsec
        ];
        enterShell = ''
          tofu version
        '';
      };

      # Custom Python 3 installation wrapped with cloud and REST libraries
      python-boto3-requests = { pkgs, ... }: {
        packages = [
          (pkgs.python3.withPackages (ps: with ps; [
            boto3
            requests
          ]))
        ];
      };

      # Ansible configuration utilities
      ansible = { pkgs, ... }: {
        packages = with pkgs; [
          ansible
        ];
        env = {
          ANSIBLE_COLLECTIONS_PATH = "/home/skd/.ansible/collections";
        };
      };
    };
  };
}
