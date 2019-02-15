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
