FROM ubuntu

RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
        gosu \
        socat \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

ENV CONTAINER_UID=${CONTAINER_UID:-1000}
ENV CONTAINER_GID=${CONTAINER_GID:-1000}
RUN groupadd -g ${CONTAINER_GID} -o udpstaff \
 && useradd -g udpstaff -m -o -u ${CONTAINER_UID} udpstaff
WORKDIR /home/udpstaff/

COPY entrypoint.sh receive_udp.sh loop_cmd.sh udp_forwarding.conf ./
RUN chmod +x ./entrypoint.sh ./receive_udp.sh ./loop_cmd.sh

# EXPOSEはudp_forwarding.conf依存のため指定しない

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./receive_udp.sh", "./udp_forwarding.conf"]
