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

# variables
: "${COLIMA_CPUS:=8}"
: "${COLIMA_MEMORY:=8}"

# check already start?
result=0
colima status default || result=$?
if [ $result -eq 0 ]; then
  exit
fi

# start colima if stop.
result=0
colima start default --cpu "${COLIMA_CPUS}" --memory "${COLIMA_MEMORY}" || result=$?
if [ $result -eq 0 ]; then
  exit
fi

# force stop and start colima if error.
result=0
limactl stop colima -f
colima start default --cpu "${COLIMA_CPUS}" --memory "${COLIMA_MEMORY}"
