FROM ubuntu

RUN set -eux \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends \
        gosu \
        dnsmasq \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

# 権限の問題があり、rootで実行するので省略
# ENV CONTAINER_UID=${CONTAINER_UID:-501}
# ENV CONTAINER_GID=${CONTAINER_GID:-20}
# RUN groupadd -g ${CONTAINER_GID} -o dnsstaff \
#  && useradd -g dnsstaff -m -o -u ${CONTAINER_UID} dnsstaff
# WORKDIR /home/dnsstaff/

COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

# デフォルトの起動引数(-A --address=...はこの後に動的に追加する)
# 長くならないように省略形を使う
# -A, --address=/<domain>/<ipaddr>                       Return ipaddr for all hosts in specified domains.
# -b, --bogus-priv                                       Fake reverse lookups for RFC1918 private address ranges.
# -D, --domain-needed                                    Do NOT forward queries with no domain part.
# -g, --group=<groupname>                                Change to this group after startup (defaults to dip).
# -h, --no-hosts                                         Do NOT load /etc/hosts file.
# -k, --keep-in-foreground                               Do NOT fork into the background, do NOT run in debug mode.
# -n, --no-poll                                          Do NOT poll /etc/resolv.conf file, reload only on SIGHUP.
# -R, --no-resolv                                        Do NOT read resolv.conf.
# -u, --user=<username>                                  Change to this user after startup. (defaults to nobody).
# -8, --log-facility=<facility>|<file>                   Log to this syslog facility or file. (defaults to DAEMON)
ENV DNSMASQ_ARGS=${DNSMASQ_ARGS:-"-b -D -h -k -n -R -u root -8 -"}
# entrypoint.shで-A "/${DNSMASQ_DOMAIN}/${DNSMASQ_ADDR}"を追加する
# DNSMASQ_{DOMAIN,ADDR}_1〜DNSMASQ_{DOMAIN,ADDR}_Nまで連番で対応(抜け番があれば停止だが、"-"はスキップ)
ENV DNSMASQ_DOMAIN=${DNSMASQ_DOMAIN:-.test}
ENV DNSMASQ_ADDR=${DNSMASQ_ADDR:-127.0.0.1}

EXPOSE 53/tcp
EXPOSE 53/udp
ENTRYPOINT ["./entrypoint.sh"]
CMD ["dnsmasq"]
