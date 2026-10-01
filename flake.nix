{
  description = "FreeShow - free and open-source presentation software";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f:
        lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

        version = "1.6.5";

        sources = {
          "x86_64-linux"  = { arch = "x86_64"; hash = "sha256-bMQpiGRtPa2W24ctkuDjL3FOtHHuUz7lBbAYtYwA8Zw="; };
          "aarch64-linux" = { arch = "arm64";  hash = "sha256-EwQSB4jiQzCiNL/c8f0Ql0sPcxJnx8xnB2Aepu0CRBM="; };
        };

    in
    {
      packages = forAllSystems (pkgs:
        let
          pname = "freeshow";
          currentConfig = sources.${pkgs.stdenv.hostPlatform.system};

          src = pkgs.fetchurl {
            url = "https://github.com/ChurchApps/FreeShow/releases/download/v${version}/FreeShow-${version}-${currentConfig.arch}.AppImage";
            hash = currentConfig.hash;
          };

          appimageContents = pkgs.appimageTools.extract {
            inherit pname version src;
          };
        in
        {
          default = pkgs.appimageTools.wrapType2 {
            inherit pname version src;

            meta = {
              description = "Free and open-source, user-friendly presenter software.";
              homepage = "https://freeshow.app";
              changelog = "https://github.com/ChurchApps/FreeShow/releases/tag/v${version}";
              license = lib.licenses.gpl3Only;
              mainProgram = "freeshow";
              platforms = builtins.attrNames sources;
              sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
            };

            extraPkgs = pkgs: with pkgs; [
              alsa-lib
              glib
              nss
              nspr
            ];

            extraInstallCommands = ''
              install -Dm444 ${appimageContents}/freeshow.desktop -t $out/share/applications

              substituteInPlace $out/share/applications/freeshow.desktop \
                --replace-fail 'Exec=AppRun' 'Exec=freeshow'

              cp -r ${appimageContents}/usr/share/icons $out/share/
            '';
          };
        }
      );
    };
}
