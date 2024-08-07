#!/usr/bin/env sh
#====================================================================
# begin of 定型文
# このスクリプトを厳格に実行
set -eu
# set -eux
# 環境に影響を受けないようにしておく
umask 0022
# PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_')
IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH
# end of 定型文
#--------------------------------------------------------------------

# 権限の問題があり、rootで実行するので省略
# UID,GIDを合わせる
# uid=$(stat -c "%u" .)
# gid=$(stat -c "%g" .)
# ug_name=dnsstaff
# if [ "${CONTAINER_GID}" != "${gid}" ]; then
#     groupmod -g "${CONTAINER_GID}" -o "${ug_name}"
# fi
# if [ "${CONTAINER_UID}" != "${uid}" ]; then
#     usermod -g "${ug_name}" -o -u "${CONTAINER_UID}" "${ug_name}"
# fi
# # コンテナ内作成ディレクトリのUID,GIDを合わせる
# mk_dirs="/home/${ug_name}"
# for mk_dir in ${mk_dirs}; do
#     uid=$(stat -c "%u" "${mk_dir}")
#     gid=$(stat -c "%g" "${mk_dir}")
#     if [ "${CONTAINER_GID}" != "${gid}" ]; then
#         chgrp -R "${CONTAINER_GID}" "${mk_dir}"
#     fi
#     if [ "${CONTAINER_UID}" != "${uid}" ]; then
#         chown -R "${CONTAINER_UID}" "${mk_dir}"
#     fi
# done

# dnsmasqコマンドなら引数を追加する
if [ "${1}" = "dnsmasq" ]; then
    # オプションを付与したいのでコマンドは消しておく
    shift
    command_is_dnsmasq=true
elif [ "${1}" = "${1#-}" ]; then
    command_is_dnsmasq=false
else
    command_is_dnsmasq=true
fi
if ${command_is_dnsmasq}; then
    skip_address=false
    if [ -z "${DNSMASQ_DOMAIN}" ]; then
        echo "DNSMASQ_DOMAIN environment variable is empty so address not added."
        skip_address=true
    fi
    if [ -z "${DNSMASQ_ADDR}" ]; then
        echo "DNSMASQ_ADDR environment variable is empty so address not added."
        skip_address=true
    fi
    if ! ${skip_address}; then
        address_args="-A /${DNSMASQ_DOMAIN}/${DNSMASQ_ADDR}"
        sequence_number=1
        while true; do
            sequence_domain=$(eval "printf $(printf "%s" "\${DNSMASQ_DOMAIN_${sequence_number}-\"\"}")")
            sequence_addr=$(eval "printf $(printf "%s" "\${DNSMASQ_ADDR_${sequence_number}-\"\"}")")
            if [ -z "${sequence_domain}" ] || [ -z "${sequence_addr}" ]; then
                # 未定義なので終了
                break
            fi
            if [ "${sequence_domain}" = "-" ] || [ "${sequence_addr}" = "-" ]; then
                echo "skip sequence number ${sequence_number} because DNSMASQ_DOMAIN_${sequence_number} or DNSMASQ_ADDR_${sequence_number} is '-'."
            else
                address_args="${address_args} -A /${sequence_domain}/${sequence_addr}"
            fi
            sequence_number=$((sequence_number + 1))
        done
        DNSMASQ_ARGS="${DNSMASQ_ARGS} ${address_args}"
    fi
    skip_server=false
    if [ -z "${DNSMASQ_SERVER}" ]; then
        echo "DNSMASQ_SERVER environment variable is empty so server not added."
        skip_server=true
    fi
    if ! ${skip_server}; then
        server_args="-S ${DNSMASQ_SERVER}"
        sequence_number=1
        while true; do
            sequence_server=$(eval "printf $(printf "%s" "\${DNSMASQ_SERVER_${sequence_number}-\"\"}")")
            if [ -z "${sequence_server}" ]; then
                # 未定義なので終了
                break
            fi
            if [ "${sequence_server}" = "-" ]; then
                echo "skip sequence number ${sequence_number} because DNSMASQ_SERVER_${sequence_number} is '-'."
            else
                server_args="${server_args} -S ${sequence_server}"
            fi
            sequence_number=$((sequence_number + 1))
        done
        DNSMASQ_ARGS="${DNSMASQ_ARGS} ${server_args}"
    fi
    # shellcheck disable=SC2086
    set -- dnsmasq ${DNSMASQ_ARGS} "$@"
    echo "$@"
fi

# 権限の問題があり、rootで実行するので省略
# if [ "$(id -u)" = "${CONTAINER_UID}" ]; then
#     exec "$@"
# else
#     # ユーザー変更してコマンド実行
#     exec /usr/sbin/gosu "${ug_name}" "$@"
# fi
exec "$@"
