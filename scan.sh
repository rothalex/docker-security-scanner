########################################################################################################################
## Aquasec Microscanner Wrapper
##
## Use this script to scan images with Aquasec Microscanner.
## Why? Because Microscanner requires you to extend your image by adding Microscanner rather than being 
## able to scan images you've already built.
##
## URL: https://github.com/lukebond/microscanner-wrapper
########################################################################################################################
#!/bin/bash
set -euo pipefail

MICROSCANNER_TOKEN="${MICROSCANNER_TOKEN:-}"
DOCKER_IMAGE="${1:-}"
TEMP_IMAGE_TAG=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' </dev/urandom | fold -w 32 | head -n 1 | tr '[:upper:]' '[:lower:]' || true)

main() {
  local MICROSCANNER_BINARY MICROSCANNER_SOURCE
  [[ -z ${MICROSCANNER_TOKEN} ]] && {
    print_usage
    exit 1
  }
  [[ -z ${DOCKER_IMAGE} ]] && {
    print_usage
    exit 1
  }

  trap cleanup EXIT

  TEMP_DIR=$(mktemp -d)
  cd "${TEMP_DIR}"

  MICROSCANNER_SOURCE="https://get.aquasec.com/microscanner"
  if MICROSCANNER_BINARY=$(command -v microscanner); then
    printf "Using local "
    microscanner --version

    cp "${MICROSCANNER_BINARY}" ./microscanner
    MICROSCANNER_SOURCE="microscanner"
    echo
  fi

  {
    echo "FROM ${DOCKER_IMAGE}"

    cat <<'EOL'
RUN if [ ! -d /etc/ssl/certs/ ] || { [ ! -f /etc/ssl/certs/ca-certificates.crt ] && [ ! -f /etc/ssl/certs/ca-bundle.crt ]; }; then \
  PACKAGE_MANAGER=$(basename \
    $({ command -v apk apt yum false 2>/dev/null || which apk apt yum false; } \
    | head -n1)); \
  if [ "${PACKAGE_MANAGER}" = "apk" ]; then \
    apk --update add ca-certificates; \
  elif [ "${PACKAGE_MANAGER}" = "apt" ]; then \
    apt update \
      && apt install --no-install-recommends -y ca-certificates \
      && update-ca-certificates; \
  elif [ "${PACKAGE_MANAGER}" = "yum" ]; then \
    yum install -y ca-certificates; \
  else \
    echo 'ca-certificates not found and package manager not apk, apt, or yum. Aborting' >&2; \
    exit 1; \
  fi; \
fi;
EOL

    cat <<EOL
ADD ${MICROSCANNER_SOURCE} .
RUN chmod +x microscanner \
  && ./microscanner --version \
  && ./microscanner ${MICROSCANNER_TOKEN}
EOL

  } | docker build -t ${TEMP_IMAGE_TAG} -f - .
}

print_usage() {
  echo "Usage: MICROSCANNER_TOKEN=xxxxxxxxxxxxxxxx ./scan.sh DOCKER_IMAGE"
}

cleanup() {
  if docker inspect --type=image "${TEMP_IMAGE_TAG}" &>/dev/null; then
    docker image rm --force "${TEMP_IMAGE_TAG}" || true
  fi
  rm -rf "${TEMP_DIR}" || true
}

main