{
  description = "experimental accessiblity project (deneysel erişilebilirlik projesi)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          nativeBuildInputs = with pkgs; [
            cmake
            ninja
            pkg-config
            libsForQt5.qt5.wrapQtAppsHook
          ];
          buildInputs = with pkgs; [
            tomlplusplus
            cli11
            magic-enum

            libsndfile
            openal

            catch2_3

            boost180
            libbacktrace
            microsoft_gsl

            fmt_9
            spdlog

            at-spi2-core
            xdotool

            libsForQt5.qt5.qtbase
          ];
          baseDerivation =
            {
              pname = "SoundsOfGuis";
              version = "0.0.0";
              src = self;
              inherit buildInputs nativeBuildInputs;

              libbacktrace_header = "${pkgs.libbacktrace}/include/backtrace.h";
              QT_LINUX_ACCESSIBILITY_ALWAYS_ON = 1;
              QT_ACCESSIBILITY = 1;
            };

        in
        {

          devShell = pkgs.mkShell baseDerivation;
          packages.default = pkgs.stdenv.mkDerivation (baseDerivation // { });


        });
}
