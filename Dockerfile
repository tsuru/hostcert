FROM jpetazzo/nsenter
ADD . /
ENTRYPOINT [ "/run.sh" ]