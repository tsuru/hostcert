#!/bin/sh

if [ -f /run.sh ]; then
    CONTENTS="$(cat /run.sh)"
    nsenter -t 1 -m -u -i -n -p /bin/sh -c "echo '${CONTENTS}' >/tmp/run.sh"
    exec nsenter -t 1 -m -u -i -n -p /bin/sh /tmp/run.sh "$@"
    exit 0
fi

CACERT="$1"
CACERT_NO_NEWLINE=$(echo "$CACERT" | tr -d '\n')
if cat /etc/ssl/certs/ca-certificates.crt | tr -d '\n' | grep -- "$CACERT_NO_NEWLINE"; then
    while true; do sleep 86400; done
    exit 0
fi

sudo mkdir -p /etc/docker/certs.d
echo "$CACERT" | sudo tee /etc/docker/certs.d/ca.pem
echo "$CACERT" | sudo tee -a /etc/ssl/certs/ca-certificates.crt
which systemctl && sudo systemctl restart docker
which restart && sudo restart docker
