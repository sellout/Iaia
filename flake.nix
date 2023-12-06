{
  description = "Total recursion schemes for Idris";

  nixConfig = {
    ## https://github.com/NixOS/rfcs/blob/master/rfcs/0045-deprecate-url-syntax.md
    extra-experimental-features = ["no-url-literals"];
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    ## Isolate the build.
    registries = false;
    sandbox = "relaxed";
  };

  outputs = {
    bash-strict-mode,
    flake-utils,
    flaky,
    nixpkgs,
    self,
  }: let
    pname = "iaia";

    supportedSystems = flake-utils.lib.defaultSystems;
  in
    {
      schemas = {
        inherit
          (flaky.schemas)
          overlays
          homeConfigurations
          packages
          devShells
          projectConfigurations
          checks
          formatter
          ;
      };

      overlays.default = final: prev: {
        default = final: prev: {
          idrisPackages = prev.idrisPackages.overrideAttrs (
            old:
              self.overlays.idris final prev old old
          );
        };

        idris = final: prev: ifinal: iprev: {
          ${pname} = self.packages.${final.system}.${pname};
        };
      };

      homeConfigurations =
        builtins.listToAttrs
        (builtins.map
          (flaky.lib.homeConfigurations.example pname self [
            ({
              lib,
              pkgs,
              ...
            }: {
              home = {
                packages = [
                  (pkgs.idrisPackages.with-packages [
                    pkgs.idrisPackages.${pname}
                  ])
                ];
                stateVersion = lib.mkForce "23.05";
              };
            })
          ])
          supportedSystems);
    }
    // flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};

      src = pkgs.lib.cleanSource ./.;
    in {
      packages = {
        default = self.packages.${system}.${pname};

        ${pname} =
          bash-strict-mode.lib.checkedDrv
          pkgs
          (pkgs.idrisPackages.build-idris-package {
            inherit pname src;

            version = "0.1.0";

            doCheck = true;

            meta = {
              description = "Total recursion schemes for Idris";
              homepage = "https://github.com/sellout/iaia";
              license = nixpkgs.lib.licenses.agpl3;
              maintainers = [nixpkgs.lib.maintainers.sellout];
            };
          });
      };

      projectConfigurations =
        flaky.lib.projectConfigurations.default {inherit pkgs self;};

      devShells = self.projectConfigurations.${system}.devShells;
      checks = self.projectConfigurations.${system}.checks;
      formatter = self.projectConfigurations.${system}.formatter;
    });

  inputs = {
    bash-strict-mode = {
      inputs = {
        flake-utils.follows = "flake-utils";
        flaky.follows = "flaky";
      };
      url = "github:sellout/bash-strict-mode";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flaky = {
      inputs = {
        bash-strict-mode.follows = "bash-strict-mode";
        flake-utils.follows = "flake-utils";
        home-manager.url = "github:nix-community/home-manager/release-23.05";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:sellout/flaky";
    };

    ## Idris is broken in Nixpkgs 23.11
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
  };
}
