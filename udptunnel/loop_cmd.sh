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

if [ -z "$1" ]; then
    echo "Usage: $0 command [args..]"
    exit 1
fi

# 終了時に子プロセスも一緒に終了させる
exit_children2 () {
    oid=$$
    IFS='
    '
    for line in $(ps -o pid,ppid); do
        pid=$(echo "$line" | awk '{print $1}')
        ppid=$(echo "$line" | awk '{print $2}')
        if [ "$ppid" != "$oid" ]; then
            continue
        fi
        ps $pid > /dev/null
        if [ $? -ne 0 ]; then
            continue
        fi
        kill $pid
    done
    exit
}
trap 'exit_children2' 1 2 3 15

retry_count=10
err_coutinue=0
while true; do
    $@ &
    wait $! && :
    err_code=$?
    if [ $err_code -ne 0 ]; then
        err_coutinue=$((err_coutinue+1))
        if [ $err_coutinue -gt $retry_count ]; then
            exit $err_code
        fi
    else
        err_coutinue=0
    fi
done
