#!/bin/sh

if [ -f /run.sh ]; then
    CONTENTS="$(cat /run.sh | base64)"
    nsenter -t 1 -m -u -i -n -p /bin/sh -c "echo '${CONTENTS}' | base64 --decode >/tmp/run.sh"
    exec nsenter -t 1 -m -u -i -n -p /bin/sh /tmp/run.sh "$@"
    exit 0
fi

CACERT="$1"
CACERT_NO_NEWLINE=$(echo "$CACERT" | tr -d '\n')

forever() {
    while true; do sleep 86400; done
    exit 0
}

if [ -z "$CACERT" ]; then
    echo 'Empty ca certificate argument, aborting...'
    forever
fi

bundle_file=""
for f in \
"/etc/ssl/certs/ca-certificates.crt" \
"/etc/pki/tls/certs/ca-bundle.crt" \
"/etc/ssl/ca-bundle.pem" \
"/etc/pki/tls/cacert.pem" \
"/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem"; do
    if [ -f $f ]; then
        bundle_file="$f"
        break
    fi
done

if [ -z "$bundle_file" ]; then
    echo 'TLS bundle not found, aborting...'
    forever
fi

echo "Using bundle file in $bundle_file"

if cat "$bundle_file" | tr -d '\n' | grep -- "$CACERT_NO_NEWLINE"; then
    echo "Bundle file in $bundle_file already updated, sleeping..."
    forever
fi

echo "Updating bundle file in $bundle_file"
sudo mkdir -p /etc/docker/certs.d
echo "$CACERT" | sudo tee /etc/docker/certs.d/hostcert.crt
echo "$CACERT" | sudo tee -a "$bundle_file"
which systemctl && sudo systemctl restart docker
which restart && sudo restart docker
