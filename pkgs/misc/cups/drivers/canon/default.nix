{ lib
, stdenv
, fetchurl
, unzip
, autoconf
, automake
, libtool_1_5
, makeWrapper
, cups
, jbigkit
, glib
, gtk3
, gdk-pixbuf
, pango
, cairo
, coreutils
, atk
, pkg-config
, gnome2
, libxml2
, runtimeShell
, libredirect
, ghostscript
, pkgs
, pkgsi686Linux
, zlib
}:

let
  system =
    if stdenv.targetPlatform.system == "x86_64-linux" then "intel"
    else if stdenv.targetPlatform.system == "aarch64-linux" then "arm"
    else throw "Unsupported platform for Canon UFR2 Drivers: ${stdenv.targetPlatform.system}";
  i686_NIX_GCC = pkgsi686Linux.callPackage ({ gcc }: gcc) { };
  ld64 = "${stdenv.cc}/nix-support/dynamic-linker";
  libs = pkgs: lib.makeLibraryPath buildInputs;

  version = "5.70";
  dl = "8/0100007658/33";

  versionNoDots = builtins.replaceStrings [ "." ] [ "" ] version;
  src_canon = fetchurl {
    url = "http://gdlp01.c-wss.com/gds/${dl}/linux-UFRII-drv-v${versionNoDots}-m17n-11.tar.gz";
    hash = "sha256-d5VHlPpUPAr3RWVdQRdn42YLuVekOw1IaMFLVt1Iu7o=";
  };

  buildInputs = [ cups zlib jbigkit glib gtk3 gnome2.libglade libxml2 gdk-pixbuf pango cairo atk ];
in
stdenv.mkDerivation rec {
  pname = "canon-cups-ufr2";
  inherit version;
  src = src_canon;

  postUnpack = ''
    (
      cd $sourceRoot
      tar -xf Sources/cnrdrvcups-lb-${version}-1.11.tar.xz
      sed -ie "s@_prefix=/usr@_prefix=$out@" cnrdrvcups-common-${version}/allgen.sh
      sed -ie "s@_libdir=/usr/lib@_libdir=$out/lib@" cnrdrvcups-common-${version}/allgen.sh
      sed -ie "s@_bindir=/usr/bin@_bindir=$out/bin@" cnrdrvcups-common-${version}/allgen.sh
      sed -ie "s@/usr@$out@" cnrdrvcups-common-${version}/{backend,rasterfilter}/Makefile.am
      sed -ie "s@etc/cngplp@$out/etc/cngplp@" cnrdrvcups-common-${version}/cngplp/Makefile.am
      sed -ie "s@usr/share/cngplp@$out/usr/share/cngplp@" cnrdrvcups-common-${version}/cngplp/src/Makefile.am
      patchShebangs cnrdrvcups-common-${version}

      sed -ie "s@_prefix=/usr@_prefix=$out@" cnrdrvcups-lb-${version}/allgen.sh
      sed -ie "s@_libdir=/usr/lib@_libdir=$out/lib@" cnrdrvcups-lb-${version}/allgen.sh
      sed -ie "s@_bindir=/usr/bin@_bindir=$out/bin@" cnrdrvcups-lb-${version}/allgen.sh
      sed -ie '/^cd \.\.\/cngplp/,/^cd files/{/^cd files/!{d}}' cnrdrvcups-lb-${version}/allgen.sh
      sed -ie "s@cd \.\./pdftocpca@cd pdftocpca@" cnrdrvcups-lb-${version}/allgen.sh
      sed -ie "s@/usr@$out@" cnrdrvcups-lb-${version}/pdftocpca/Makefile.am
      sed -i "/CNGPLPDIR/d" cnrdrvcups-lb-${version}/Makefile
      patchShebangs cnrdrvcups-lb-${version}
    )
  '';

  nativeBuildInputs = [ makeWrapper unzip autoconf automake libtool_1_5 pkg-config ];

  inherit buildInputs;

  installPhase = ''
    runHook preInstall

    (
      cd cnrdrvcups-common-${version}
      ./allgen.sh
      make install
    )
    (
      cd cnrdrvcups-common-${version}/Rule
      mkdir -p $out/share/usb
      install -m 644 *.usb-quirks $out/share/usb
    )
    (
      cd cnrdrvcups-lb-${version}
      ./allgen.sh
      make install

      mkdir -p $out/share/cups/model
      install -m 644 ppd/*.ppd $out/share/cups/model/
    )
    '' + lib.optionalString (system == "intel") ''
    (
      cd lib
      mkdir -p $out/lib32
      install -m 755 libs32/intel/libColorGearCufr2.so.2.0.0 $out/lib32
      install -m 755 libs32/intel/libcaepcmufr2.so.1.0 $out/lib32
      install -m 755 libs32/intel/libcaiocnpkbidir.so.1.0.0 $out/lib32
      install -m 755 libs32/intel/libcaiousb.so.1.0.0 $out/lib32
      install -m 755 libs32/intel/libcaiowrapufr2.so.1.0.0 $out/lib32
      install -m 755 libs32/intel/libcanon_slimufr2.so.1.0.0 $out/lib32
      install -m 755 libs32/intel/libcanonufr2r.so.1.0.0 $out/lib32
      install -m 755 libs32/intel/libcnaccm.so.1.0 $out/lib32
      install -m 755 libs32/intel/libcnlbcmr.so.1.0 $out/lib32
      install -m 755 libs32/intel/libcnncapcmr.so.1.0 $out/lib32
      install -m 755 libs32/intel/libufr2filterr.so.1.0.0 $out/lib32
    )
    '' + ''
    (
      cd lib
      mkdir -p $out/lib
      install -m 755 libs64/${system}/libColorGearCufr2.so.2.0.0 $out/lib
      install -m 755 libs64/${system}/libcaepcmufr2.so.1.0 $out/lib
      install -m 755 libs64/${system}/libcaiocnpkbidir.so.1.0.0 $out/lib
      install -m 755 libs64/${system}/libcaiousb.so.1.0.0 $out/lib
      install -m 755 libs64/${system}/libcaiowrapufr2.so.1.0.0 $out/lib
      install -m 755 libs64/${system}/libcanon_slimufr2.so.1.0.0 $out/lib
      install -m 755 libs64/${system}/libcanonufr2r.so.1.0.0 $out/lib
      install -m 755 libs64/${system}/libcnaccm.so.1.0 $out/lib
      install -m 755 libs64/${system}/libcnlbcmr.so.1.0 $out/lib
      install -m 755 libs64/${system}/libcnncapcmr.so.1.0 $out/lib
      install -m 755 libs64/${system}/libufr2filterr.so.1.0.0 $out/lib

      install -m 755 libs64/${system}/cnpdfdrv $out/bin
      install -m 755 libs64/${system}/cnpkbidir $out/bin
      install -m 755 libs64/${system}/cnpkmoduleufr2r $out/bin
      install -m 755 libs64/${system}/cnrsdrvufr2 $out/bin
      install -m 755 libs64/${system}/cnsetuputil2 $out/bin/cnsetuputil2

      mkdir -p $out/share/cnpkbidir
      install -m 644 libs64/${system}/cnpkbidir_info* $out/share/cnpkbidir

      mkdir -p $out/share/ufr2filter
      install -m 644 libs64/${system}/ThLB* $out/share/ufr2filter
    )

    '' + lib.optionalString (system == "intel") ''
    (
      cd $out/lib32
      ln -sf libcaepcmufr2.so.1.0 libcaepcmufr2.so
      ln -sf libcaepcmufr2.so.1.0 libcaepcmufr2.so.1
      ln -sf libcaiowrapufr2.so.1.0.0 libcaiowrapufr2.so
      ln -sf libcaiowrapufr2.so.1.0.0 libcaiowrapufr2.so.1
      ln -sf libcanon_slimufr2.so.1.0.0 libcanon_slimufr2.so
      ln -sf libcanon_slimufr2.so.1.0.0 libcanon_slimufr2.so.1
      ln -sf libufr2filterr.so.1.0.0 libufr2filterr.so
      ln -sf libufr2filterr.so.1.0.0 libufr2filterr.so.1

      patchelf --set-rpath "$(cat ${i686_NIX_GCC}/nix-support/orig-cc)/lib:${libs pkgsi686Linux}:${pkgsi686Linux.stdenv.cc.libc}/lib:${pkgsi686Linux.libxml2.out}/lib:$out/lib32" libcanonufr2r.so.1.0.0
      patchelf --set-rpath "$(cat ${i686_NIX_GCC}/nix-support/orig-cc)/lib:${libs pkgsi686Linux}:${pkgsi686Linux.stdenv.cc.libc}/lib" libcaepcmufr2.so.1.0
      patchelf --set-rpath "$(cat ${i686_NIX_GCC}/nix-support/orig-cc)/lib:${libs pkgsi686Linux}:${pkgsi686Linux.stdenv.cc.libc}/lib" libColorGearCufr2.so.2.0.0
    )
    '' + ''

    (
      cd $out/lib
      ln -sf libcaepcmufr2.so.1.0 libcaepcmufr2.so
      ln -sf libcaepcmufr2.so.1.0 libcaepcmufr2.so.1
      ln -sf libcaiowrapufr2.so.1.0.0 libcaiowrapufr2.so
      ln -sf libcaiowrapufr2.so.1.0.0 libcaiowrapufr2.so.1
      ln -sf libcanon_slimufr2.so.1.0.0 libcanon_slimufr2.so
      ln -sf libcanon_slimufr2.so.1.0.0 libcanon_slimufr2.so.1
      ln -sf libufr2filterr.so.1.0.0 libufr2filterr.so
      ln -sf libufr2filterr.so.1.0.0 libufr2filterr.so.1

      patchelf --set-rpath "$(cat $NIX_CC/nix-support/orig-cc)/lib:${libs pkgs}:${stdenv.cc.cc.lib}/lib64:${stdenv.cc.libc}/lib64:$out/lib" libcanonufr2r.so.1.0.0
      patchelf --set-rpath "$(cat $NIX_CC/nix-support/orig-cc)/lib:${libs pkgs}:${stdenv.cc.cc.lib}/lib64:${stdenv.cc.libc}/lib64" libcaepcmufr2.so.1.0
      patchelf --set-rpath "$(cat $NIX_CC/nix-support/orig-cc)/lib:${libs pkgs}:${stdenv.cc.cc.lib}/lib64:${stdenv.cc.libc}/lib64" libColorGearCufr2.so.2.0.0
    )

    (
      cd $out/bin
      patchelf --set-interpreter "$(cat ${ld64})" --set-rpath "${lib.makeLibraryPath buildInputs}:${stdenv.cc.cc.lib}/lib64:${stdenv.cc.libc}/lib64" cnsetuputil2
      patchelf --set-interpreter "$(cat ${ld64})" --set-rpath "${lib.makeLibraryPath buildInputs}:${stdenv.cc.cc.lib}/lib64:${stdenv.cc.libc}/lib64" cnpdfdrv
      patchelf --set-interpreter "$(cat ${ld64})" --set-rpath "${lib.makeLibraryPath buildInputs}:${stdenv.cc.cc.lib}/lib64:${stdenv.cc.libc}/lib64:$out/lib" cnpkbidir
      patchelf --set-interpreter "$(cat ${ld64})" --set-rpath "${lib.makeLibraryPath buildInputs}:${stdenv.cc.cc.lib}/lib64:${stdenv.cc.libc}/lib64:$out/lib" cnrsdrvufr2

      wrapProgram $out/bin/cnsetuputil2 \
        --set LD_PRELOAD "${libredirect}/lib/libredirect.so" \
        --set NIX_REDIRECTS /usr/share/cnsetuputil2=$out/usr/share/cnsetuputil2
    )

    (
      cd lib/data/ufr2
      mkdir -p $out/share/caepcm
      install -m 644 *.ICC $out/share/caepcm
      install -m 644 *.icc $out/share/caepcm
      install -m 644 *.PRF $out/share/caepcm
      install -m 644 CnLB* $out/share/caepcm
    )

    (
      cd cnrdrvcups-utility-${version}/data
      mkdir -p $out/usr/share/cnsetuputil2
      install -m 644 cnsetuputil* $out/usr/share/cnsetuputil2
    )

    makeWrapper "${ghostscript}/bin/gs" "$out/bin/gs" \
      --prefix LD_LIBRARY_PATH ":" "$out/lib" \
      --prefix PATH ":" "$out/bin"

    runHook postInstall
  '';

  meta = with lib; {
    description = "CUPS Linux drivers for Canon printers";
    homepage = "http://www.canon.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [
      # please consider maintaining if you are updating this package
    ];
  };
}
