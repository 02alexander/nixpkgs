{ lib, fetchFromGitHub, buildPythonApplication, pexpect, pyyaml, openssh }:

buildPythonApplication rec{
  pname = "xxh";
  version = "0.8.7";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    hash = "sha256-AKfiFBaV8DC/Z7Bc+ZpwcJor/mzYomUaQKKobKXICn4=";
  };

  propagatedBuildInputs = [ pexpect pyyaml openssh ];

  meta = with lib; {
    description = "Bring your favorite shell wherever you go through ssh";
    homepage = "https://github.com/xxh/xxh";
    license = licenses.bsd2;
    maintainers = [ maintainers.pasqui23 ];
  };
}
