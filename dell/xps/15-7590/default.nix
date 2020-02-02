{ lib, ... }:

{
  imports = [
    ../../../common/cpu/intel
    ../../../common/pc/laptop
    ../../../common/pc/ssd
  ];

  # TODO: boot loader
  #boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.kernelPackages = pkgs.linuxPackages_5_1;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # The 48.ucode causes the Killer wifi card to crash.
  # The iwlfwifi-cc-a0-46.ucode works perfectly
  nixpkgs.pkgs = import <nixpkgs> {
    config.allowUnfree = true;
    overlays = [
      (self: super: {
        firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
          src = super.fetchgit{
            url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
            rev = "bf13a71b18af229b4c900b321ef1f8443028ded8";
            sha256 = "1dcaqdqyffxiadx420pg20157wqidz0c0ca5mrgyfxgrbh6a4mdj";
          };
          postInstall = ''
            rm $out/lib/firmware/iwlwifi-cc-a0-48.ucode
          '';
          outputHash = "0dq48i1cr8f0qx3nyq50l9w9915vhgpwmwiw3b4yhisbc3afyay4";
        });
      })
    ];
  };
}
