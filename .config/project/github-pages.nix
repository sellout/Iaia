{lib, ...}: let
  defaultBranch = "main";
in {
  services.github = {
    settings.pages = {
      build_type = "workflow";
      source.branch = defaultBranch;
    };
    workflow."pages.yml".text = lib.generators.toYAML {} {
      name = "Deploy generated docs to Pages";

      on = {
        # Runs on pushes targeting the default branch
        push.branches = [defaultBranch];
        # Allows you to run this workflow manually from the Actions tab
        workflow_dispatch = null;
      };

      # Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
      permissions = {
        contents = "read";
        id-token = "write";
        pages = "write";
      };

      # Allow only one concurrent deployment, skipping runs queued between the
      # run in-progress and latest queued. However, do NOT cancel in-progress
      # runs as we want to allow these production deployments to complete.
      concurrency = {
        cancel-in-progress = false;
        group = "pages";
      };

      jobs = {
        build = {
          runs-on = "ubuntu-latest";
          steps = [
            {
              name = "Checkout";
              uses = "actions/checkout@v4";
            }
            {
              name = "Setup Pages";
              uses = "actions/configure-pages@v3";
            }
            {
              uses = "cachix/install-nix-action@v23";
              "with".extra_nix_config = ''
                extra-substituters = https://cache.garnix.io
                extra-trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
              '';
            }
            {
              uses = "lriesebos/nix-develop-command@v1";
              "with" = {
                command = ''
                  idris --mkdoc iaia.ipkg
                  ## We copy here to fix the permissions from the Nix symlinks
                  cp -r ./iaia_doc ./_site
                  chmod --recursive +rwx ./_site
                '';
                devshell = "iaia";
              };
            }
            {
              name = "Upload artifact";
              uses = "actions/upload-pages-artifact@v2";
            }
          ];
        };
        deploy = {
          environment = {
            name = "github-pages";
            url = "\${{ steps.deployment.outputs.page_url }}";
          };
          runs-on = "ubuntu-latest";
          needs = "build";
          steps = [
            {
              name = "Deploy to GitHub Pages";
              id = "deployment";
              uses = "actions/deploy-pages@v2";
            }
          ];
        };
      };
    };
  };
}
