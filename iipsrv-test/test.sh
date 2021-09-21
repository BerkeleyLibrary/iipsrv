#!/usr/bin/env bash

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
EXPECTED="${TEST_DIR}/default.jpg"
ACTUAL="/tmp/default.jpg"

if ! curl -v 'http://localhost/iiif/test.tif/info.json' ; then
  echo 'IIIF information request failed'
  exit 1
else
  echo 'IIIF information request successful'
fi

if ! curl -v 'http://localhost/iiif/test.tif/full/64,/0/default.jpg' > "${ACTUAL}" ; then
  echo 'IIIF image request failed'
  exit 1
else
  echo 'IIIF image request successful'
fi

if ! cmp "${EXPECTED}" "${ACTUAL}" ; then
  echo 'Image returned from iipsrv did not match expected'
  exit 1
else
  echo 'Image returned from iipsrv matches expected'
fi
