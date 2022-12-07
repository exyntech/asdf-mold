#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for mold.
GH_REPO="https://github.com/rui314/mold"
TOOL_NAME="mold"
TOOL_TEST="mold --help"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

log() {
  echo -e "asdf-$TOOL_NAME: [INFO] $*"
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if mold is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if mold has other means of determining installable versions.
  list_github_tags
}

download_binary() {
  local version filepath url
  version="$1"
  filepath="$2"

  local platforms=()
  local kernel arch
  kernel="$(uname -s)"
  arch="$(uname -m)"

  case "$kernel" in
  Linux)
    platforms=("${arch}-linux")
    ;;
  esac

  log "Downloading $TOOL_NAME release $version..."
  for platform in "${platforms[@]}"; do
    url="$GH_REPO/releases/download/v${version}/${TOOL_NAME}-${version}-${platform}.tar.gz"
    log "Trying ${url} ..."
    curl "${curl_opts[@]}" -o "$filepath" -C - "$url" && return 0
  done

  return 1
}

extract() {
  local archive_path=$1
  local target_dir=$2

  tar -xzf "$archive_path" -C "$target_dir" --strip-components=1 || fail "Could not extract $archive_path"
}

binary_download_and_extract() {
  # Puts the extracted files in $ASDF_DOWNLOAD_PATH/bin

  local version=$1
  local download_dir=$2

  local extract_dir="${download_dir}"
  mkdir -p "$extract_dir"

  local download_file="${download_dir}/${TOOL_NAME}-${version}-bin.tar.gz"

  if download_binary "$version" "${download_file}"; then
    extract "${download_file}" "${extract_dir}"
    rm "${download_file}"
    return 0
  fi

  return 1
}

download_and_extract() {

  local install_type="$1"
  local version="$2"
  local download_dir="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
    # TODO: support refs
  fi

  ## Binary Download & Extract
  if binary_download_and_extract "$version" "${download_dir}"; then
    return 0
  else
    fail "Could not find a suitable binary download for $TOOL_NAME $version. Source install is not yet supported."
  fi
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"/

    # TODO: Assert mold executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
