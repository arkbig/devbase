#!/usr/bin/env sh
#====================================================================
# begin of 定型文
# このスクリプトを厳格に実行
set -u
# set -eux
# 環境に影響を受けないようにしておく
umask 0022
# PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_')
IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH
# end of 定型文
#--------------------------------------------------------------------

# ファイル からudp:tcpリストを受け取る
if [ -z "$1" ]; then
    echo "Usage: $0 <udp_forwarding.conf> [kill]"
    exit 1
else
    # 後でkillするとき検索できるようにフルパスにする
    self_sh=$(
        cd "$(dirname "$0")"
        pwd
    )/$(basename "$0")
    read_from=$(
        cd "$(dirname "$1")"
        pwd
    )/$(basename "$1")
    if [ "${self_sh}" != "$0" ] || [ "${read_from}" != "$1" ]; then
        shift
        exec "${self_sh}" "${read_from}" "$@"
    fi
fi
same_pid=$(pgrep -fo "^(/bin/)?sh +${self_sh} +${read_from}$")
if [ $# -ge 2 ]; then
    if [ "$2" = "kill" ]; then
        if [ -n "${same_pid}" ] && [ "$$" != "${same_pid}" ]; then
            # shellcheck disable=SC2086
            kill ${same_pid}
        fi
        exit
    else
        echo "Usage: $0 <udp_forwarding.conf> [kill]"
        exit 1
    fi
else
    if [ -n "${same_pid}" ] && [ "$$" != "${same_pid}" ]; then
        echo "Already running pid ${same_pid}"
        exit
    fi
fi

# 終了時に子プロセスも一緒に終了させる
exit_children() {
    oid=$$
    IFS=$(printf '\n_')
    IFS=${IFS%_}
    for pid in $(pgrep -P "${oid}"); do
        if ! ps "${pid}" >/dev/null; then
            continue
        fi
        kill "${pid}"
    done
    exit
}
trap 'exit_children' 1 2 3 15

loop_cmd=$(
    cd "$(dirname "$0")"
    pwd
)/loop_cmd.sh
while read -r line; do
    # "#〜"はコメント
    line=$(printf "%s" "${line}" | sed -e 's/#.*//')
    if [ -z "${line}" ]; then
        continue
    fi
    dest_host=$(printf "%s" "${line}" | cut -f 1 -d : -s)
    udp_port=$(printf "%s" "${line}" | cut -f 2 -d : -s)
    tcp_port=$(printf "%s" "${line}" | cut -f 3 -d : -s)
    forward_port=$(printf "%s" "${line}" | cut -f 4 -d : -s)
    if [ -z "${forward_port}" ]; then
        forward_port="${tcp_port}"
        tcp_port="${udp_port}"
        udp_port="${dest_host}"
        dest_host=127.0.0.1
    fi
    if [ -n "${udp_port}" ] && [ -n "${tcp_port}" ]; then
        cmd="socat ${UDPTUNNEL_ARGS--s} TCP4-LISTEN:$tcp_port,reuseaddr,fork UDP:$dest_host:$forward_port"
        echo "Run: ${cmd}"
        # shellcheck disable=SC2086
        "${loop_cmd}" ${cmd} &
    fi
done <"${read_from}"

# 子プロセスの終了を待つ
wait
