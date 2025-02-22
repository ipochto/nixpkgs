{ lib
, buildPythonPackage
, fetchPypi
, python
, coverage
}:

buildPythonPackage rec {
  version = "1.3.7";
  pname = "nose";

  src = fetchPypi {
    inherit pname version;
    sha256 = "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98";
  };

  # 2to3 was removed in setuptools 58
  postPatch = ''
    substituteInPlace setup.py \
      --replace "'use_2to3': True," ""

    substituteInPlace setup3lib.py \
      --replace "from setuptools.command.build_py import Mixin2to3" "from distutils.util import Mixin2to3"
  '';

  preBuild = lib.optionalString
      ((python.isPy3k or false) && (python.pname != "pypy3"))
  ''
    2to3 -wn nose functional_tests unit_tests
  '';

  propagatedBuildInputs = [ coverage ];

  doCheck = false;  # lot's of transient errors, too much hassle
  checkPhase = if python.is_py3k or false then ''
    ${python}/bin/${python.executable} setup.py build_tests
  '' else "" + ''
    rm functional_tests/test_multiprocessing/test_concurrent_shared.py* # see https://github.com/nose-devs/nose/commit/226bc671c73643887b36b8467b34ad485c2df062
    ${python}/bin/${python.executable} selftest.py
  '';

  meta = with lib; {
    description = "A unittest-based testing framework for python that makes writing and running tests easier";
    homepage = "http://readthedocs.org/docs/nose/";
    license = licenses.lgpl3;
  };

}
