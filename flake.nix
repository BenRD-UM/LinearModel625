{
  description = "Development environment for linear model 625 package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { pkgs, ... }:
        let
          # Tools for developing any R package
          devTooling = with pkgs.rPackages; [
            devtools
            usethis
            roxygen2
            testthat
            covr
            pkgdown
            lintr
            styler
            languageserver
            DT
            htmltools
          ];

          # Keep in sync with Imports + Suggests in DESCRIPTION
          pkgDeps = with pkgs.rPackages; [
            cli
            rlang
            dplyr
          ];

          rPkgs = devTooling ++ pkgDeps;
        in
        {
          devShells.default = pkgs.mkShell {
            packages = [
              (pkgs.rWrapper.override { packages = rPkgs; })
              (pkgs.rstudioWrapper.override { packages = rPkgs; })
              pkgs.pandoc # vignettes / README.Rmd
              pkgs.qpdf   # R CMD check --as-cran
              pkgs.git
            ];

            # Writable project-local library, so devtools::install()
            # works without touching the Nix store
            shellHook = ''
              export R_LIBS_USER="$PWD/.Rlib"
              mkdir -p "$R_LIBS_USER"
            '';
          };
        };
    };
}
