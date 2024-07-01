FROM ubuntu

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    gosu \
    openssl \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

ENV CONTAINER_UID=${CONTAINER_UID:-1000}
ENV CONTAINER_GID=${CONTAINER_GID:-1000}
RUN groupadd -g ${CONTAINER_GID} -o castaff \
    && useradd -g castaff -m -o -u ${CONTAINER_UID} castaff \
    && mkdir /certs \
    && chown castaff:castaff /certs
VOLUME ["/certs"]
WORKDIR /home/castaff/

COPY entrypoint.sh generatecerts.sh ./
RUN chmod +x ./entrypoint.sh ./generatecerts.sh
ENTRYPOINT ["./entrypoint.sh"]
CMD ["./generatecerts.sh"]
