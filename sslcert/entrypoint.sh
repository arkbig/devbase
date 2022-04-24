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

# UID,GIDを合わせる
uid=$(stat -c "%u" .)
gid=$(stat -c "%g" .)
ug_name=dnsstaff
if [ ${CONTAINER_GID} -ne ${gid} ]; then
    groupmod -g ${CONTAINER_GID} -o ${ug_name}
    chgrp -R ${CONTAINER_GID} .
fi
if [ ${CONTAINER_UID} -ne ${uid} ]; then
    usermod -g ${ug_name} -o -u ${CONTAINER_UID} ${ug_name}
fi

if [ $(id -u) -eq ${CONTAINER_UID} ]; then
    exec $@
else
    # ユーザー変更してコマンド実行
    exec /usr/sbin/gosu ${ug_name} $@
fi
