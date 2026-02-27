{
  description = "OWASP Modsec";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachSystem  [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        dockerImageBase = pkgs.dockerTools.pullImage {
          imageName = "owasp/modsecurity-crs";
          imageDigest = "sha256:c88099f4efc0d85ad09913bf6de25f98f02ad263143793c4248c6ecedc417095";
          hash = "sha256-h+wzR/U1A5BzKrEfOpIEya7sxngULcMMpisyYuUr8xQ=";
          finalImageName = "owasp/modsecurity-crs";
          finalImageTag = "latest";
        };
        backend = builtins.getEnv "BACKEND";
        imageName = builtins.getEnv "IMAGE";
        imageTag = builtins.getEnv "IMAGE_TAG";
      in
      {
        packages = {
          default = pkgs.dockerTools.buildLayeredImage {
            name = "${imageName}";
            tag = "${imageTag}";
            fromImage = dockerImageBase;
            config = {
              Env = [
                "ACCESSLOG=/dev/stdout"
                "ALLOWED_HTTP_VERSIONS=HTTP/1.1 HTTP/2 HTTP/2.0"
                "ALLOWED_METHODS=GET"
                "ALLOWED_REQUEST_CONTENT_TYPE_CHARSET=utf-8"
                "ANOMALY_INBOUND=5"
                "ANOMALY_OUTBOUND=5"
                "BACKEND=${backend}"
                "BLOCKING_PARANOIA=2"
                "CRS_ENABLE_TEST_MARKER=1"
                "DETECTION_PARANOIA=2"
                "ENFORCE_BODYPROC_URLENCODED=1"
                "ERRORLOG=/dev/stderr"
                "LOGLEVEL=warn"
                "METRICSLOG=/dev/stdout"
                "MODSEC_AUDIT_ENGINE=on"
                "MODSEC_AUDIT_LOG=/dev/stdout"
                "MODSEC_DEBUG_LOG=/dev/stderr"
                "MODSEC_REQ_BODY_ACCESS=on"
                "MODSEC_RESP_BODY_ACCESS=on"
                "MODSEC_RULE_ENGINE=on"
                "PARANOIA=2"
                "PORT=8080"
                "TIMEOUT=30"
                "VALIDATE_UTF8_ENCODING=1"
              ];
              Cmd = [
                "nginx"
                "-g"
                "daemon off;"
              ];
              ENTRYPOINT = [
                "/docker-entrypoint.sh"
              ];
            };
          };
        };
      });
}
