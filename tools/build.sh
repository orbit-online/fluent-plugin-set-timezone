#!/usr/bin/env bash

set -e

main() {
  docker build --build-arg "RUBY_VERSION=${RUBY_VERSION:-2.6.0}" -t fluent-plugin-set-timezone:latest .
  docker run --rm \
    -v "$PWD/pkg:/plugin/pkg:rw" \
    fluent-plugin-set-timezone:latest
}
(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && main)
