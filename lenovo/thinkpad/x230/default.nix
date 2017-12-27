{ config, lib, pkgs, ... }:

{
  imports = [
    ../.
    ../../../common/cpu/intel
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      acpi_call
    ];
    kernelModules = [
      "acpi_call"
      "tpm-rng"
    ];
  };
}
