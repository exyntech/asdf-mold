#!/usr/bin/env bash

set -euo pipefail

mold_path=$(asdf where mold)

echo -n "${mold_path}/libexec/mold/"
