{
  description = "FreeShow presentation software for multiple architectures";

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
          version = "1.6.3";

          archConfigs = {
            "x86_64-linux" = {
              url = "https://github.com/ChurchApps/FreeShow/releases/download/v1.6.3/FreeShow-1.6.3-x86_64.AppImage";
              hash = "sha256-IgfZdiqrDI26As+NvfbApTiCKOFxlw5ZpBE0ec/W45s=";
            };
            "aarch64-linux" = {
              url = "https://github.com/ChurchApps/FreeShow/releases/download/v1.6.3/FreeShow-1.6.3-arm64.AppImage";
              hash = "sha256-QR7UD1cPkex7m+E4sOAhhLubxVf4CbdpO5KY6sF6BGM=";
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
