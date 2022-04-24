#!/usr/bin/env sh
#====================================================================
# begin of 定型文
# このスクリプトを厳格に実行
set -eu
# set -eux
# 環境に影響を受けないようにしておく
umask 0022
# PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH
# end of 定型文
#--------------------------------------------------------------------

# 専用のDebian-eximが使われる
# UID,GIDを合わせる
# uid=$(stat -c "%u" .)
# gid=$(stat -c "%g" .)
# ug_name=smtpstaff
# if [ ${CONTAINER_GID} -ne ${gid} ]; then
#     groupmod -g ${CONTAINER_GID} -o ${ug_name}
#     chgrp -R ${CONTAINER_GID} .
# fi
# if [ ${CONTAINER_UID} -ne ${uid} ]; then
#     usermod -g ${ug_name} -o -u ${CONTAINER_UID} ${ug_name}
# fi

# eximコマンドなら設定ファイルを編集する
if [ "${1}" = "exim" ]; then
    command_is_exim=true
elif [ "${1}" = "${1#-}" ]; then
    command_is_exim=false
else
    set -- exim "$@"
    command_is_exim=true
fi
if ${command_is_exim}; then
    # リレールートファイル作成
    echo '' > /etc/exim4/relay_routes
    skip_relay=false
    if [ -z "${EXIM4_RELAY_DOMAIN}" ]; then
        echo "EXIM4_RELAY_DOMAIN environment variable is empty so relay not added."
        skip_relay=true
    fi
    if [ -z "${EXIM4_RELAY_ADDR}" ]; then
        echo "EXIM4_RELAY_ADDR environment variable is empty so relay not added."
        skip_relay=true
    fi
    if ! ${skip_relay}; then
        echo "${EXIM4_RELAY_DOMAIN}: ${EXIM4_RELAY_ADDR}" > /etc/exim4/relay_routes
        sequence_number=1
        while true; do
            sequence_domain=$(eval "printf $(printf \"\${EXIM4_RELAY_DOMAIN_${sequence_number}-\"\"}\")")
            sequence_addr=$(eval "printf $(printf \"\${EXIM4_RELAY_ADDR_${sequence_number}-\"\"}\")")
            if [ -z ${sequence_domain} ] || [ -z ${sequence_addr} ]; then
                # 未定義なので終了
                break
            fi
            if [ "${sequence_domain}" = "-" ] || [ "${sequence_addr}" = "-" ]; then
                echo "skip sequence number ${sequence_number} because EXIM4_RELAY_DOMAIN_${sequence_number} or EXIM4_RELAY_ADDR_${sequence_number} is '-'."
            else
                echo "${sequence_domain}: ${sequence_addr}" >> /etc/exim4/relay_routes
            fi
            sequence_number=$((sequence_number+1))
        done
    fi
    echo /etc/exim4/relay_routes 
    cat /etc/exim4/relay_routes

    # 設定ファイル更新
    sed -i s/dc_smarthost=.*/dc_smarthost=\'${EXIM4_SMARTHOST}\'/ /etc/exim4/update-exim4.conf.conf
    update-exim4.conf -v
fi

# 専用のDebian-eximが使われる
# if [ $(id -u) -eq ${CONTAINER_UID} ]; then
#     exec $@
# else
#     # ユーザー変更してコマンド実行
#     exec /usr/sbin/gosu ${ug_name} $@
# fi
exec $@
