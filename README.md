# Update host certificates

This image is meant to update host root CA certificates from inside a
container.

## Example

Using docker run:
```
docker run --rm --privileged --pid=host tsuru/hostcert "$(cat MY_CA.pem)"
```

Using tsuru node-containers:
```
tsuru node-container-add hostcert -r 'hostconfig.pidmode=host' -r "config.cmd.0=$(cat MY_CA.pem)" --image tsuru/hostcert --privileged
```

Using a DaemonSet:
```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: hostcert
spec:
  selector:
    matchLabels:
      app: hostcert
  template:
    metadata:
      labels:
        app: hostcert
    spec:
      hostPID: true
      containers:
      - name: hostcert
        image: tsuru/hostcert
        securityContext:
          privileged: true
        args: 
        - |
          -----BEGIN CERTIFICATE-----
          MIIZOzCCBSOgAwIBAgIBATANBgkqhdiG930BAQ0FADCB4DELMAxGA1UEBhMCQlIx
          ...
          -----END CERTIFICATE-----
```