FROM ubuntu

RUN set -eux \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends \
        dnsmasq \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

# 権限の問題があり、rootで実行するので省略
# ENV CONTAINER_UID=${CONTAINER_UID:-1000}
# ENV CONTAINER_GID=${CONTAINER_GID:-1000}
# RUN groupadd -g ${CONTAINER_GID} -o dnsstaff \
#  && useradd -g dnsstaff -m -o -u ${CONTAINER_UID} dnsstaff
# WORKDIR /home/dnsstaff/

COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

# デフォルトの起動引数
# 長くならないように省略形を使う
# -A, --address=/<domain>/<ipaddr>                       Return ipaddr for all hosts in specified domains.
# -h, --no-hosts                                         Do NOT load /etc/hosts file.
# -k, --keep-in-foreground                               Do NOT fork into the background, do NOT run in debug mode.
# -n, --no-poll                                          Do NOT poll /etc/resolv.conf file, reload only on SIGHUP.
# -R, --no-resolv                                        Do NOT read resolv.conf.
# -S, --server=/<domain>/<ipaddr>                        Specify address(es) of upstream servers with optional domains.
# -u, --user=<username>                                  Change to this user after startup. (defaults to nobody).
# -8, --log-facility=<facility>|<file>                   Log to this syslog facility or file. (defaults to DAEMON)
# これらの後に-Aと-Sを動的に追加する
ENV DNSMASQ_ARGS=${DNSMASQ_ARGS:-"-h -k -n -R -u root -8 -"}
# entrypoint.shで-A "/${DNSMASQ_DOMAIN}/${DNSMASQ_ADDR}"を追加する
# DNSMASQ_{DOMAIN,ADDR}_1〜DNSMASQ_{DOMAIN,ADDR}_Nまで連番で対応(抜け番があれば停止だが、"-"はスキップ)
ENV DNSMASQ_DOMAIN=${DNSMASQ_DOMAIN:-.test}
ENV DNSMASQ_ADDR=${DNSMASQ_ADDR:-192.168.100.100}
# entrypoint.shで-S "${DNSMASQ_SERVER}"を追加する
# DNSMASQ_SERVER_1〜DNSMASQ_SERVER_Nまで連番で対応(抜け番があれば停止だが、"-"はスキップ)
ENV DNSMASQ_SERVER=1.1.1.1

EXPOSE 53/tcp
EXPOSE 53/udp
ENTRYPOINT ["./entrypoint.sh"]
CMD ["dnsmasq"]
