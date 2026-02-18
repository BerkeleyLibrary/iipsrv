#!/usr/bin/env bash

############################################################
# Helper functions

# shellcheck disable=SC2155
download() {
  local download_url="${1}"
  local output_path="${2}"

  if ! curl -v "${download_url}" > "${output_path}" ; then
    echo "Downloading ${download_url} to ${output_path} failed"
    exit 1
  else
    echo "Downloaded ${download_url} to ${output_path}"
    echo
  fi
}

# shellcheck disable=SC2155
assert_identical() {
  local expected_file="${1}"
  local actual_file="${2}"

  if ! cmp "${expected_file}" "${actual_file}"; then
    echo "${actual_file} did not match expected ${expected_file}"

    local expected_md5=$(md5sum "${expected_file}")
    local expected_size=$(wc -c "${expected_file}" | /usr/bin/grep -Eo '[[:digit:]]+')

    echo "Expected: ${expected_md5}"
    echo "          ${expected_size} bytes"

    local actual_md5=$(md5sum "${actual_file}")
    local actual_size=$(wc -c "${actual_file}" | /usr/bin/grep -Eo '[[:digit:]]+')

    echo "Actual:   ${actual_md5}"
    echo "          ${actual_size} bytes"

    exit 1
  else
    echo "${actual_file} matches expected ${expected_file}"
    echo
  fi
}

############################################################
# Fixture

HEALTHCHECK_URL='http://localhost/health'
INFO_URL='http://localhost/iiif/test.tif/info.json'
IMAGE_URL='http://localhost/iiif/test.tif/full/64,/0/default.jpg'

EXPECTED_HEALTHCHECK_PATH="test/health.html"
EXPECTED_INFO_PATH="test/info.json"
EXPECTED_IMAGE_PATH="test/default.jpg"

ARTIFACTS_DIR="artifacts"
ACTUAL_HEALTHCHECK_PATH="${ARTIFACTS_DIR}/health.html"
ACTUAL_INFO_PATH="${ARTIFACTS_DIR}/info.json"
ACTUAL_IMAGE_PATH="${ARTIFACTS_DIR}/default.jpg"

############################################################
# Setup

echo '------------------------------------------------------------'
echo 'Creating artifacts directory:'
echo

if ! mkdir -p "${ARTIFACTS_DIR}" ; then
  echo "Unable to create artifacts directory ${ARTIFACTS_DIR} in $(pwd)"
fi
echo "Created $(realpath "${ARTIFACTS_DIR}")"
echo

############################################################
# Tests

echo '------------------------------------------------------------'
echo 'Making healthcheck request:'
echo
download "${HEALTHCHECK_URL}" "${ACTUAL_HEALTHCHECK_PATH}"
echo

echo '------------------------------------------------------------'
echo 'Verifying healthcheck result:'
echo
assert_identical "${EXPECTED_HEALTHCHECK_PATH}" "${ACTUAL_HEALTHCHECK_PATH}"

echo '------------------------------------------------------------'
echo 'Making IIIF info request:'
echo
download "${INFO_URL}" "${ACTUAL_INFO_PATH}"
echo

echo '------------------------------------------------------------'
echo 'Verifying IIIF info result:'
echo
assert_identical "${EXPECTED_INFO_PATH}" "${ACTUAL_INFO_PATH}"

echo '------------------------------------------------------------'
echo 'Making IIIF image request:'
echo
download "${IMAGE_URL}" "${ACTUAL_IMAGE_PATH}"
echo

echo '------------------------------------------------------------'
echo 'Verifying IIIF image result:'
echo
assert_identical "${EXPECTED_IMAGE_PATH}" "${ACTUAL_IMAGE_PATH}"
