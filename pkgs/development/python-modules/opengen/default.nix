{
  lib,
  fetchPypi,
  buildPythonPackage,
  pythonOlder,

  setuptools,
  jinja2,
  casadi,
  pyyaml,
  retry,
  numpy,
}:
buildPythonPackage rec {
  pname = "opengen";
  version = "0.9.4";
  # disabled = pythonOlder "3.10";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jKsxOPoUEu+3FOy+TZ06uK04BKTtB2kehOIIhpkAnLM=";
  };

  build-system = [
    setuptools
    casadi
  ];

  dependencies = [
    jinja2
    casadi
    pyyaml
    retry
    numpy
  ];

  meta = {
    description = "Code generation tool for OpEn";
    longDescription = ''
      Code generation tool for the OpEn optimization engine
    '';
    homepage = "https://github.com/python-control/python-control";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ _02alexander ];
    platforms = lib.platforms.all;
  };
}
