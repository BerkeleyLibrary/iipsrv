echo '------------------------------------------------------------'
realpath "${0}"
echo

# TODO: find a less janky way to get tests to work in CI
#       (then update README)
DEFAULT_FILESYSTEM_PREFIX='/opt/app/test/data/'
if [ -z "${FILESYSTEM_PREFIX}" ]; then
  echo "FILESYSTEM_PREFIX not set; using ${DEFAULT_FILESYSTEM_PREFIX}"
  export FILESYSTEM_PREFIX="${DEFAULT_FILESYSTEM_PREFIX}"
else
  echo "FILESYSTEM_PREFIX=${FILESYSTEM_PREFIX}"
fi
echo

echo 'Starting nginx'
echo
service nginx start

echo 'Starting iipsrv.fcgi'
echo
spawn-fcgi -n -f /iipsrv/iipsrv.fcgi -p 9000
