{
  flake-utils,
  flaky,
  nixpkgs,
  nixpkgs-23_05,
  self,
  systems,
}: let
  pname = "iaia";

  supportedSystems = import systems;
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

    lib = {};

    homeConfigurations =
      builtins.listToAttrs
      (builtins.map
        (flaky.lib.homeConfigurations.example self [
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
    pkgs = nixpkgs.legacyPackages.${system}.appendOverlays [
      flaky.overlays.default
    ];
    pkgs-23_05 = import nixpkgs-23_05 {inherit system;};

    src = pkgs.lib.cleanSource ../..;
  in {
    packages = {
      default = self.packages.${system}.${pname};

      ${pname} = pkgs.checkedDrv (pkgs-23_05.idrisPackages.build-idris-package {
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
  })
