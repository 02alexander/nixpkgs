{
  lib,
  fetchPypi,
  buildPythonPackage,
  pythonOlder,

  gfortran,
  blas,
  cmake,
  scikit-build,
  setuptools,
  setuptools-scm,

  # depedencies
  numpy
}:
buildPythonPackage rec {
  pname = "slycot";
  version = "0.6.0";
  disabled = pythonOlder "3.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-mOzxnK0MbODW9NuVFp78FPiaKFrCSkqNocpblrnaPCM=";
  };

  build-system = [
    cmake
    scikit-build
    setuptools
    setuptools-scm
    gfortran
  ];

  dontUseCmakeConfigure = true;

  buildInputs = [
    blas
  ];

  dependencies = [
    numpy
  ];

  meta = {
    description = "Python wrapper for selected SLICOT routines.";
    longDescription = ''
      Python wrapper for selected SLICOT routines, notably including solvers for Riccati, Lyapunov, and Sylvester equations.
    '';
    homepage = "https://github.com/python-control/Slycot";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ _02alexander ];
    platforms = lib.platforms.all;
  };
}
