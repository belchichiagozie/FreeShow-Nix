{
    description = "FreeShow - free and open-source presentation software";

    inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"

    outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = lib.genAttrs supportedSystems;

      # `nix run .#update` rewrites the version and hashes below.
      version = "1.6.5";

      sources = {
        x86_64-linux = {
          suffix = "x86_64";
          hash = "sha256-bMQpiGRtPa2W24ctkuDjL3FOtHHuUz7lBbAYtYwA8Zw=";
        };
        aarch64-linux = {
          suffix = "arm64";
          hash = "sha256-EwQSB4jiQzCiNL/c8f0Ql0sPcxJnx8xnB2Aepu0CRBM=";
        };
      };

      mkFreeshow =
        pkgs:
        let
          pname = "freeshow";

          source =
            sources.${pkgs.stdenv.hostPlatform.system}
              or (throw "freeshow: unsupported system ${pkgs.stdenv.hostPlatform.system}");

          src = pkgs.fetchurl {
            url = "https://github.com/ChurchApps/FreeShow/releases/download/v${version}/FreeShow-${version}-${source.suffix}.AppImage";
            inherit (source) hash;
          };

          appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
        in
        pkgs.appimageTools.wrapType2 {
          inherit pname version src;

          extraPkgs =
            pkgs: with pkgs; [
              alsa-lib
              glib
              nss
              nspr
            ];

          extraInstallCommands = ''
            desktop=$(find ${appimageContents} -maxdepth 1 -name '*.desktop' | head -n1)
            if [ -n "$desktop" ]; then
              install -Dm444 "$desktop" $out/share/applications/freeshow.desktop
              sed -i 's|^Exec=.*|Exec=freeshow %U|' $out/share/applications/freeshow.desktop
            fi
            if [ -d ${appimageContents}/usr/share/icons ]; then
              mkdir -p $out/share
              cp -r ${appimageContents}/usr/share/icons $out/share/
            fi
          '';

          meta = {
            description = "Free and open-source presenter software for lyrics, media and stage display";
            homepage = "https://freeshow.app";
            changelog = "https://github.com/ChurchApps/FreeShow/releases/tag/v${version}";
            license = lib.licenses.gpl3Only;
            mainProgram = "freeshow";
            platforms = builtins.attrNames sources;
            sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
          };
        };
        in
        {
          packages = forAllSystems (system: rec {
            freeshow = mkFreeshow nixpkgs.legacyPackages.${system};
            default = freeshow;
          });

          apps = forAllSystems (
            system:
            let
              pkgs = nixpkgs.legacyPackages.${system};
            in
            {
              default = {
                type = "app";
                program = lib.getExe self.packages.${system}.default;
              };

              # Run from a checkout: nix run .#update
              update = {
                type = "app";
                program = lib.getExe (
                  pkgs.writeShellApplication {
                    name = "freeshow-update";
                    runtimeInputs = with pkgs; [
                      curl
                      jq
                      gnused
                      git
                      nix
                    ];
                    text = ''
                      cd "$(git rev-parse --show-toplevel)"

                      latest=$(curl -fsSL https://api.github.com/repos/ChurchApps/FreeShow/releases/latest | jq -r .tag_name | sed 's/^v//')
                      current=$(sed -nE 's/^ *version = "([^"]+)";.*/\1/p' flake.nix)

                      if [ "$latest" = "$current" ]; then
                        echo "freeshow is up to date ($current)"
                        exit 0
                      fi

                      echo "Updating freeshow $current -> $latest"

                      while IFS=: read -r system suffix; do
                        url="https://github.com/ChurchApps/FreeShow/releases/download/v$latest/FreeShow-$latest-$suffix.AppImage"
                        hash=$(nix --extra-experimental-features nix-command store prefetch-file --json "$url" | jq -r .hash)
                        sed -i -E "/$system = \{/,/\};/ s|hash = \"[^\"]+\";|hash = \"$hash\";|" flake.nix
                      done <<EOF
                      x86_64-linux:x86_64
                      aarch64-linux:arm64
                      EOF

                      sed -i -E "s|^( *version = \")[^\"]+(\";)|\1$latest\2|" flake.nix
                      echo "Done. Review with git diff, then run: nix build .#freeshow"
                    '';
                  }
                );
              };
            }
          );

          overlays.default = final: _prev: {
            freeshow = mkFreeshow final;
          };

          formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

}
