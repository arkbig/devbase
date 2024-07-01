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

# UID,GIDを合わせる
uid=$(stat -c "%u" .)
gid=$(stat -c "%g" .)
ug_name=castaff
if [ "${CONTAINER_GID}" != "${gid}" ]; then
    groupmod -g "${CONTAINER_GID}" -o "${ug_name}"
fi
if [ "${CONTAINER_UID}" != "${uid}" ]; then
    usermod -g "${ug_name}" -o -u "${CONTAINER_UID}" "${ug_name}"
fi
# コンテナ内作成ディレクトリのUID,GIDを合わせる
mk_dirs="/home/${ug_name} /certs"
for mk_dir in ${mk_dirs}; do
    uid=$(stat -c "%u" "${mk_dir}")
    gid=$(stat -c "%g" "${mk_dir}")
    if [ "${CONTAINER_GID}" != "${gid}" ]; then
        chgrp -R "${CONTAINER_GID}" "${mk_dir}"
    fi
    if [ "${CONTAINER_UID}" != "${uid}" ]; then
        chown -R "${CONTAINER_UID}" "${mk_dir}"
    fi
done

if [ "$(id -u)" = "${CONTAINER_UID}" ]; then
    exec "$@"
else
    # ユーザー変更してコマンド実行
    exec /usr/sbin/gosu "${ug_name}" "$@"
fi
