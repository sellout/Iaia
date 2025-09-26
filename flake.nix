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
    nixpkgs-23_05,
    self,
  }: let
    pname = "iaia";

    supportedSystems = flaky.lib.defaultSystems;
  in
    {
      schemas = {
        inherit
          (flaky.schemas)
          schemas
          overlays
          packages
          devShells
          projectConfigurations
          checks
          ;
      };

      overlays = {
        default = final: prev: let
          pkgs-23_05 = import nixpkgs-23_05 {inherit (final) system;};
        in {
          idrisPackages = prev.idrisPackages.override {
            ## NB: 23.11 doesn’t have a working Idris, so this provides one that
            ##     should work regardless.
            idris-no-deps = pkgs-23_05.idrisPackages.idris-no-deps;
            overrides = self.overlays.idris final prev;
          };
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
      pkgs-23_05 = import nixpkgs-23_05 {inherit system;};

      src = pkgs.lib.cleanSource ./.;
    in {
      packages = {
        default = self.packages.${system}.${pname};

        ${pname} =
          bash-strict-mode.lib.checkedDrv
          pkgs
          (pkgs-23_05.idrisPackages.build-idris-package {
            inherit pname src;

            version = "0.2.0";

            idrisDeps = [pkgs-23_05.idrisPackages.comonad];

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

      devShells =
        ## TODO: Some Haskell packages (like pandoc) have issues on i686. But it
        ##       should be possible to just disable checks or something in most
        ##       cases.
        if system == "i686-linux"
        then {}
        else
          self.projectConfigurations.${system}.devShells
          // {default = flaky.lib.devShells.default system self [] "";};
      checks = self.projectConfigurations.${system}.checks;
      formatter = self.projectConfigurations.${system}.formatter;
    });

  inputs = {
    bash-strict-mode = {
      inputs = {
        flake-utils.follows = "flake-utils";
        flaky.follows = "flaky";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:sellout/bash-strict-mode";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flaky = {
      inputs = {
        bash-strict-mode.follows = "bash-strict-mode";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:sellout/flaky";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";

    ## Idris is broken in Nixpkgs 23.11
    nixpkgs-23_05.url = "github:NixOS/nixpkgs/release-23.05";
  };
}
