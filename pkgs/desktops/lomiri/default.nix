{ lib
, pkgs
, libsForQt5
}:

let
  packages = self: let
    inherit (self) callPackage;
  in {
    #### Development tools / libraries
    cmake-extras = callPackage ./development/cmake-extras { };
  };
in
  lib.makeScope libsForQt5.newScope packages
