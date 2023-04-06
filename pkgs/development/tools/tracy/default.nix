{ stdenv, lib, darwin, fetchFromGitHub
, tbb, glfw, pkg-config, freetype, Carbon, AppKit, capstone, dbus, hicolor-icon-theme
}:

let
  disableLTO = stdenv.cc.isClang && stdenv.isDarwin;  # workaround issue #19098
in stdenv.mkDerivation rec {
  pname = "tracy";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "wolfpld";
    repo = "tracy";
    rev = "v${version}";
    sha256 = "sha256-K1lQNRS8+ju9HyKNVXtHqslrPWcPgazzTitvwkIO3P4";
  };

  patches = [ ]
    ++ lib.optionals (stdenv.isDarwin && !(lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11")) [ ./0001-remove-unifiedtypeidentifiers-framework ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ glfw capstone ]
    ++ lib.optionals stdenv.isDarwin [ Carbon AppKit freetype ]
    ++ lib.optionals (stdenv.isDarwin && lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11") [ darwin.apple_sdk.frameworks.UniformTypeIdentifiers ]
    ++ lib.optionals stdenv.isLinux [ tbb dbus hicolor-icon-theme freetype ];

  env.NIX_CFLAGS_COMPILE = toString ([ ]
    # Apple's compiler finds a format string security error on
    # ../../../server/TracyView.cpp:649:34, preventing building.
    ++ lib.optional stdenv.isDarwin "-Wno-format-security"
    ++ lib.optional stdenv.isLinux "-ltbb"
    ++ lib.optional stdenv.cc.isClang "-faligned-allocation"
    ++ lib.optional disableLTO "-fno-lto");

  NIX_CFLAGS_LINK = lib.optional disableLTO "-fno-lto";

  buildPhase = ''
    make -j $NIX_BUILD_CORES -C profiler/build/unix release LEGACY=1
    make -j $NIX_BUILD_CORES -C import-chrome/build/unix/ release
    make -j $NIX_BUILD_CORES -C capture/build/unix/ release
    make -j $NIX_BUILD_CORES -C update/build/unix/ release
  '';

  installPhase = ''
    install -D ./profiler/build/unix/Tracy-release $out/bin/Tracy
    install -D ./import-chrome/build/unix/import-chrome-release $out/bin/import-chrome
    install -D ./capture/build/unix/capture-release $out/bin/capture
    install -D ./update/build/unix/update-release $out/bin/update
  '';

  postFixup = lib.optionalString stdenv.isDarwin ''
    install_name_tool -change libcapstone.4.dylib ${capstone}/lib/libcapstone.4.dylib $out/bin/Tracy
  '';

  meta = with lib; {
    description = "A real time, nanosecond resolution, remote telemetry frame profiler for games and other applications";
    homepage = "https://github.com/wolfpld/tracy";
    platforms = platforms.linux ++ platforms.darwin;
    license = licenses.bsd3;
    maintainers = with maintainers; [ mpickering nagisa ];
  };
}
