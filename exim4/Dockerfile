FROM ubuntu

RUN set -eux \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends \
        exim4 \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

# Debian-eximユーザー&グループが作られて、デーモン設定で起動するとそれが使われる
# ENV CONTAINER_UID=${CONTAINER_UID:-501}
# ENV CONTAINER_GID=${CONTAINER_GID:-20}
# RUN groupadd -g ${CONTAINER_GID} -o smtpstaff \
#  && useradd -g smtpstaff -m -o -u ${CONTAINER_UID} smtpstaff
# WORKDIR /home/smtpstaff/

# exim4.conf.templateは初期設定をコピーしてきて一部追記したものです。
# 追記箇所には"## NOTE: Custimezed by arkbig"の目印を書いてます。
COPY exim4.conf.localmacros exim4.conf.template update-exim4.conf.conf /etc/exim4/
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

# 通常のメール転送先
ENV EXIM4_SMARTHOST=mailhog::1025
# 送信先が$EXIM4_RELAY_DOMAINなら$EXIM4_RELAY_ADDRへ転送する
# EXIM4_RELAY_{DOMAIN,ADDR}_1〜EXIM4_RELAY_{DOMAIN,ADDR}_Nまで連番で対応(抜け番があれば停止だが、"-"はスキップ)
ENV EXIM4_RELAY_DOMAIN=''
ENV EXIM4_RELAY_ADDR=''

EXPOSE 587

ENTRYPOINT ["./entrypoint.sh"]
# -bd   This option runs Exim as a daemon, awaiting incoming SMTP connections.
# -q<qflags><time>   When a time value is present, the -q option causes Exim to run as a daemon,
#                    starting a queue runner process at intervals specified by the given time value.
# -v   This option causes Exim to write information to the standard error stream, describing what it is doing.
CMD ["exim", "-bd", "-q10m", "-v"]
