{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "lune";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "filiptibell";
    repo = "lune";
    rev = "v${version}";
    hash = "sha256-ZVETw+GdkrR2V8RrHAWBR+avAuN0158DlJkYBquju8E=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-zOjDT8Sn/p3YaG+dWyYxSWUOo11p9/WG3EyNagZRtQQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  checkFlags = [
    # these all require internet access
    "--skip=tests::net_request_codes"
    "--skip=tests::net_request_compression"
    "--skip=tests::net_request_methods"
    "--skip=tests::net_request_query"
    "--skip=tests::net_request_redirect"
    "--skip=tests::net_socket_wss"
    "--skip=tests::net_socket_wss_rw"
    "--skip=tests::roblox_instance_custom_async"
    "--skip=tests::serde_json_decode"

    # this tries to use the root directory as the CWD
    "--skip=tests::process_spawn_cwd"
  ];

  meta = with lib; {
    description = "A standalone Luau script runtime";
    homepage = "https://github.com/lune-org/lune";
    changelog = "https://github.com/lune-org/lune/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mpl20;
    maintainers = with maintainers; [ lammermann ];
  };
}
