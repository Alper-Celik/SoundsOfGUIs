{
  description = "experimental accessiblity project (deneysel erişilebilirlik projesi)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem (with flake-utils.lib ;[ system.x86_64-linux system.aarch64-linux ])
      (system:
        let
          pkgs = (import nixpkgs
            {
              inherit system;
              overlays = [
                (self: super: {
                  ccacheWrapper = super.ccacheWrapper.override {
                    # from https://nixos.wiki/wiki/CCache#Non-NixOS
                    # and some modifications
                    extraConfig = ''
                      export CCACHE_COMPRESS=1
                      old_ccache_dir=$CCACHE_DIR
                      export CCACHE_DIR="/var/cache/ccache"
                      export CCACHE_UMASK=007
                      if [ ! -d "$CCACHE_DIR" ]; then
                        # echo "====="
                        # echo "Directory '$CCACHE_DIR' does not exist"
                        # echo "Please create it with:"
                        # echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
                        # echo "  sudo chown root:nixbld '$CCACHE_DIR'"
                        # echo "defaulting to previus ccache_dir"
                        # echo "====="
                        CCACHE_DIR=$old_ccache_dir
                      fi
                      if [ ! -w "$CCACHE_DIR" ]; then
                        # echo "====="
                        # echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
                        # echo "Please verify its access permissions"
                        # echo "defaulting to previus ccache_dir"
                        # echo "====="
                        CCACHE_DIR=$old_ccache_dir
                      fi
                    '';
                  };
                })
              ];
            });
        in
        {

          devShells =
            {
              default = (pkgs.libsForQt5.callPackage ./default.nix {
                src = self;
                # mkDerivation = pkgs.mkShell;
                stdenv = pkgs.ccacheStdenv;
              }).overrideAttrs (
                oldAttrs: {
                  QT_LINUX_ACCESSIBILITY_ALWAYS_ON = 1;
                  QT_ACCESSIBILITY = 1;
                }
              );
            };
          # packages.default = (pkgs.libsForQt5.callPackage ./default.nix {
          #   src = self;
          # });

        }
      );
}
