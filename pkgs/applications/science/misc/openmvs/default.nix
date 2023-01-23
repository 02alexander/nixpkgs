{ lib
, boost
, breakpad
, ceres-solver
, cgal
, cmake
, eigen
, fetchFromGitHub
, glfw
, libjpeg
, libpng
, libtiff
, opencv
, openmp
, pkg-config
, stdenv
, vcg
, zstd
}:

let
  boostWithZstd = boost.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ zstd ];
  });
in
stdenv.mkDerivation rec {
  version = "2.1.0";
  pname = "openmvs";

  src = fetchFromGitHub {
    owner = "cdcseacave";
    repo = "openmvs";
    rev = "v${version}";
    sha256 = "sha256-eqNprBgR0hZnbLKLZLJqjemKxHhDtGblmaSxYlmegsc=";
    fetchSubmodules = true;
  };

  # SSE is enabled by default
  cmakeFlags = lib.optional (!stdenv.isx86_64) "-DOpenMVS_USE_SSE=OFF";

  buildInputs = [
    boostWithZstd
    breakpad
    ceres-solver
    cgal
    eigen
    glfw
    libjpeg
    libpng
    libtiff
    opencv
    openmp
    vcg
  ];

  nativeBuildInputs = [ cmake pkg-config ];

  postFixup = ''
    mv $out/bin/OpenMVS/* $out/bin
    rmdir $out/bin/OpenMVS
  '';

  meta = {
    description = "Open Multi-View Stereo reconstruction library";
    homepage = "https://github.com/cdcseacave/openMVS";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ bouk ];
  };
}
