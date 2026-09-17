{
  description = "FreeShow presentation software";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f (import nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (pkgs:
        let
          version = "1.6.5";

          archConfigs = {
            "x86_64-linux" = {
              url = "https://github.com/ChurchApps/FreeShow/releases/download/v1.6.5/FreeShow-1.6.5-x86_64.AppImage";
              hash = "sha256-bMQpiGRtPa2W24ctkuDjL3FOtHHuUz7lBbAYtYwA8Zw=";
            };
            "aarch64-linux" = {
              url = "https://github.com/ChurchApps/FreeShow/releases/download/v1.6.5/FreeShow-1.6.5-arm64.AppImage";
              hash = "sha256-EwQSB4jiQzCiNL/c8f0Ql0sPcxJnx8xnB2Aepu0CRBM=";
            };
          };

          currentConfig = archConfigs.${pkgs.system};
        in
        {
          default = pkgs.appimageTools.wrapType2 {
            pname = "freeshow";
            inherit version;

            src = pkgs.fetchurl {
              url = currentConfig.url;
              hash = currentConfig.hash;
            };

            extraPkgs = pkgs: with pkgs; [
              alsa-lib
              glib
              nss
              nspr
            ];
          };
        }
      );
    };
}
