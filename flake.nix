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
          imageDigest = "sha256:b243df371398b1eeb5bc764d7b8f9e2e13927b842edd1de7565740c49a871db0";
          hash = "sha256-h+wzR/U1A5BzKrEfOpIEya7sxngULcMMpisyYuUr8xQ=";
          finalImageName = "owasp/modsecurity-crs";
          finalImageTag = "latest";
        };
        backend = builtins.getEnv "BACKEND";
      in
      {
        packages = {
          default = pkgs.dockerTools.buildLayeredImage {
            name = "registry.fly.io/nix-owasp-modsec";
            tag = "${self.shortRev}";
            fromImage = dockerImageBase;

            config = {
              Env = [
                "MODSEC_AUDIT_ENGINE=on"
                "LOGLEVEL=warn"
                "BLOCKING_PARANOIA=2"
                "DETECTION_PARANOIA=2"
                "ENFORCE_BODYPROC_URLENCODED=1"
                "ANOMALY_INBOUND=10"
                "ANOMALY_OUTBOUND=5"
                "ALLOWED_METHODS=\"GET POST\""
                "ALLOWED_REQUEST_CONTENT_TYPE_CHARSET=\"utf-8\""
                "ALLOWED_HTTP_VERSIONS=\"HTTP/1.1 HTTP/2 HTTP/2.0\""
                "RESTRICTED_EXTENSIONS=\".cmd/ .com/ .config/ .dll/\""
                "RESTRICTED_HEADERS=\"/proxy/ /if/\""
                "STATIC_EXTENSIONS=\"/.jpg/ /.jpeg/ /.png/ /.gif/\""
                "MAX_NUM_ARGS=128"
                "ARG_NAME_LENGTH=50"
                "ARG_LENGTH=200"
                "TOTAL_ARG_LENGTH=6400"
                "MAX_FILE_SIZE=100000"
                "COMBINED_FILE_SIZES=1000000"
                "TIMEOUT=60"
                "PORT=8080"
                "MODSEC_RULE_ENGINE=on"
                "MODSEC_REQ_BODY_ACCESS=on"
                "MODSEC_REQ_BODY_LIMIT=13107200"
                "MODSEC_REQ_BODY_NOFILES_LIMIT=131072"
                "MODSEC_RESP_BODY_ACCESS=on"
                "MODSEC_RESP_BODY_LIMIT=524288"
                "MODSEC_PCRE_MATCH_LIMIT=1000"
                "MODSEC_PCRE_MATCH_LIMIT_RECURSION=1000"
                "VALIDATE_UTF8_ENCODING=1"
                "CRS_ENABLE_TEST_MARKER=1"
                "BACKEND=\"${backend}\""
              ];
            };
          };
        };
      });
}