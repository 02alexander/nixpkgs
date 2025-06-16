{
  lib,
  fetchPypi,
  buildPythonPackage,
  pythonOlder,

  setuptools,
  setuptools-scm,

  # depedencies
  numpy,
  matplotlib,
  scipy,
  slycot,
}:
buildPythonPackage rec {
  pname = "control";
  version = "0.10.1";
  disabled = pythonOlder "3.10";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-O7oULJJ02Jbv2oyaIar2HdONZz1tQHFKeYnRQ0KOc4w=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    matplotlib
    scipy
    slycot
  ];

  meta = {
    description = "Python control systems library.";
    longDescription = ''
      Implements basic operations for analysis and design of feedback control systems.
    '';
    homepage = "https://github.com/python-control/python-control";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ _02alexander ];
    platforms = lib.platforms.all;
  };
}
