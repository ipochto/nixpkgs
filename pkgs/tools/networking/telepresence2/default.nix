{ lib, buildGoModule, fetchFromGitHub, kubernetes-helm }:

buildGoModule rec {
  pname = "telepresence2";
  version = "2.5.4";

  src = fetchFromGitHub {
    owner = "telepresenceio";
    repo = "telepresence";
    rev = "v${version}";
    sha256 = "sha256-v6E1v89cVL4N8eKJ5pKU6BwQWZF5lLs4VLGhUS5J1rA=";
  };

  # The Helm chart is go:embed'ed as a tarball in the binary.
  # That tarball is generated by running ./build-aux/package_embedded_chart/main.go,
  # which tries to invoke helm from tools/bin/helm.
  # Oh well…
  preBuild = ''
    mkdir -p tools/bin
    ln -sfn ${kubernetes-helm}/bin/helm tools/bin/helm
    go run ./build-aux/package_embedded_chart/main.go ${src.rev}
  '';

  vendorSha256 = "sha256-RDXP7faijMujAV19l9NmI4xk0Js6DE5YZoHRo2GHyoU=";

  ldflags = [
    "-s" "-w" "-X=github.com/telepresenceio/telepresence/v2/pkg/version.Version=${src.rev}"
  ];

  subPackages = [ "cmd/telepresence" ];

  meta = with lib; {
    description = "Local development against a remote Kubernetes or OpenShift cluster";
    homepage = "https://www.getambassador.io/docs/telepresence/2.1/quick-start/";
    license = licenses.asl20;
    maintainers = with maintainers; [ mausch ];
  };
}
