# FreeShow-Nix
An unofficial Nix Flake to package and run [FreeShow](https://github.com/ChurchApps/FreeShow) on NixOS. Supports both `x86_64-linux` and `aarch64-linux` (ARM64).

## Features
- Reproducible installation with Nix Flakes
- Supports x86_64-linux
- Supports aarch64-linux
- Uses the official upstream FreeShow release
- No AppImage required

## Installation

### Run once

nix run github:belchichiagozie/FreeShow-Nix

### Add to your flake

```nix
inputs.freeshow.url = "github:belchichiagozie/FreeShow-Nix";
