{ stdenv
, lib
, runCommand
, fetchurl
, autoPatchelfHook
, dpkg
, gtk3
, openssl_1_1
, pcsclite
, unzip
}:

stdenv.mkDerivation rec {
  pname = "pcsc-safenet";
  version = "10.8.28";

  # extract debian package from larger zip file
  src = runCommand "sac.deb" {
    zipSrc = let
      versionWithUnderscores = builtins.replaceStrings ["."] ["_"] version;
    in fetchurl {
      url = "https://www.digicert.com/StaticFiles/SAC_${versionWithUnderscores}_GA_Build.zip";
      hash = "sha256-bh+TB7ZGDMh9G4lcPtv7mc0XeGhmCfMMqrlqtyGIIaA=";
    };
    debName = "SAC ${version} GA Build/Installation/Standard/Ubuntu-2004/safenetauthenticationclient_${version}_amd64.deb";
  } ''
    ${unzip}/bin/unzip -p "$zipSrc" "$debName" >"$out"
  '';

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  buildInputs = [
    gtk3
    openssl_1_1
    pcsclite
  ];

  runtimeDependencies = [
    openssl_1_1
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  installPhase = ''
    mv usr/* .

    mkdir -p pcsc/drivers
    mv -- lib/pkcs11/* pcsc/drivers/
    rmdir lib/pkcs11

    mkdir "$out"
    cp -r ./* "$out/"

    (
      cd "$out/lib/" || exit
      for f in *.so.*.*.*; do
        ln -sf "$f" "''${f%.*}" || exit
        ln -sf "$f" "''${f%.*.*}" || exit
        ln -sf "$f" "''${f%.*.*.*}" || exit
      done
    ) || exit

    (
      cd "$out/pcsc/drivers" || exit
      for f in *; do
        if [[ ! -e $f && -e ../../lib/$f ]]; then
          ln -sf ../../lib/"$f" "$f" || exit
        fi
      done
    ) || exit

    ln -sf ${lib.getLib openssl_1_1}/lib/libcrypto.so $out/lib/libcrypto.so.1.1.0
  '';

  dontAutoPatchelf = true;

  # Patch DYN shared libraries (autoPatchElfHook only patches EXEC | INTERP).
  postFixup = ''
    autoPatchelf "$out"

    runtime_rpath="${lib.makeLibraryPath runtimeDependencies}"

    for mod in $(find "$out" -type f -name '*.so.*'); do
      mod_rpath="$(patchelf --print-rpath "$mod")"
      patchelf --set-rpath "$runtime_rpath:$mod_rpath" "$mod"
    done;
  '';

  meta = with lib; {
    homepage = "https://safenet.gemalto.com/multi-factor-authentication/security-applications/authentication-client-token-management";
    description = "Safenet Authentication Client";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ wldhx ];
  };
}
