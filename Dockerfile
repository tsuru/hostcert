FROM jpetazzo/nsenter
ADD ./run.sh /
ENTRYPOINT [ "/run.sh" ]