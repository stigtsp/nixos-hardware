{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption types;
  inherit (pkgs) fetchurl;

  inherit (pkgs.callPackage ../linux-package.nix { }) linuxPackage repos;

  cfg = config.microsoft-surface;

  version = "6.5.3";
  extraMeta.branch = "6.4"; # XXX: Using 6.4 patches, yolo
  patchDir = repos.linux-surface + "/patches/${extraMeta.branch}";
  kernelPatches = pkgs.callPackage ./patches.nix {
    inherit (lib) kernel;
    inherit version patchDir;
  };

  kernelPackages = linuxPackage {
    inherit version extraMeta kernelPatches;
    src = fetchurl {
      url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
      hash = "sha256-TKwT97F72Nz5AyrWj5Ejq1MT1pjJ9ZQWBDFlFQdj608=";
    };
  };


in {
  options.microsoft-surface.kernelVersion = mkOption {
    type = types.enum [ "6.5.3" ];
  };

  config = mkIf (cfg.kernelVersion == "6.5.3") {
    boot = {
      inherit kernelPackages;
    };
  };
}
