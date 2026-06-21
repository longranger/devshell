# Reusable Development Shell Modules

This repository contains declarative, atomic development shell modules powered by [devenv](https://devenv.sh/) and [Nix](https://nixos.org/). It serves as a centralized source of environment configurations, allowing downstream projects to dynamically compose their workspaces.

## Available Modules

The following granular `devenv` modules are exported:

*   **`opentofu`**: Includes `tenv` (OpenTofu and Terraform version manager), `tflint`, and `tfsec`.
*   **`python-boto3-requests`**: Provides a Python 3 interpreter wrapped with `boto3` and `requests` for cloud operations.
*   **`ansible`**: Sets up `ansible` and configures the default collection search path (`ANSIBLE_COLLECTIONS_PATH`).

## Usage Example

To consume these modules inside a local project, create a `flake.nix` that imports this repository and lists the desired building blocks in the `modules` array:

```nix
{
  description = "Local IaC Development Shell";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:longranger/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.devenv.follows = "devenv";
  };

  outputs = { self, nixpkgs, devenv, systems, devshell, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forEachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              devshell.devenvModules.opentofu
              devshell.devenvModules.python-boto3-requests
            ];
          };
        });
    };
}
```

Running `nix develop` or loading the shell via `direnv allow` automatically activates the environment.
