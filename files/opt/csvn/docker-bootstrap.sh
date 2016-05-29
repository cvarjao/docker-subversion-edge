#!/bin/bash

set -e
set -u
function onSignal {
  echo "Gracefully stopping services..."
  /opt/csvn/bin/csvn-httpd stop
  /opt/csvn/bin/csvn stop
  echo "Done."
}

trap onSignal SIGINT SIGTERM SIGKILL SIGSTOP
CSVN_HTTPS_PORT="$(grep -s 'jetty.ssl.port' /opt/csvn/data/conf/csvn-wrapper.conf |  cut -d'=' -f3)"
CSVN_URL="https://localhost:${CSVN_HTTPS_PORT}/csvn/"

echo "Starting CSVN Console -- ${CSVN_URL}"
/opt/csvn/bin/csvn console >/dev/null &

while ! curl -s -k -I -m 5 "${CSVN_URL}" | grep 'HTTP/1.1 '; do echo 'Waiting for CSVN Console ...'; sleep 2; done


SVN_URL_PORT="$(grep -s Listen /opt/csvn/data/conf/csvn_main_httpd.conf |  cut -d' ' -f2)"
SVN_URL_PROTO="$(if grep -s SSLCertificateKeyFile /opt/csvn/data/conf/csvn_main_httpd.conf >/dev/null; then echo 'https'; else echo 'http'; fi)"
SVN_URL="${SVN_URL_PROTO}://localhost:${SVN_URL_PORT}/svn/"

echo "Starting SVN/ViewVC -- ${SVN_URL}"
/opt/csvn/bin/csvn-httpd start >/dev/null &

while ! curl -s -k -I -m 5 "${SVN_URL}" | grep 'HTTP/1.1 '; do echo 'Waiting for SVN/ViewVC ...'; sleep 2; done

echo "Ready!"
wait
