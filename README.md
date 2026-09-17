# FreeShow-Nix
An unofficial Nix Flake to package and run [FreeShow](https://github.com/ChurchApps/FreeShow) on NixOS.


## Run Once

```sh
nix run github:belchichiagozie/FreeShow-Nix
```

## Adding to NixOS Configuration

In flake.nix:

```nix
inputs.freeshow.url = "github:belchichiagozie/FreeShow-Nix";

nixpkgs.overlays = [
  (final: prev: {
    freeshow = inputs.freeshow.packages.${prev.system}.default;
  })
];
```

In configuration.nix:

```nix
environment.systemPackages = with pkgs; [
  freeshow
];
```
