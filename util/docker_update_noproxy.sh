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

: "${no_proxy:=''}"

# For container
docker_conf="$HOME/.docker/config.json"
echo "${docker_conf}"
sed -n "s/\"noProxy\":.*/\"noProxy\": \"${no_proxy}\",/p" "${docker_conf}"
sed -i "s/\"noProxy\":.*/\"noProxy\": \"${no_proxy}\",/"  "${docker_conf}"

# For daemon
dockerd_conf="/etc/systemd/system/docker.service.d/override.conf"
echo ${dockerd_conf}
sudo sed -n "s/'no_proxy=.*'/'no_proxy=${no_proxy}'/p" "${dockerd_conf}"
sudo sed -i "s/'no_proxy=.*'/'no_proxy=${no_proxy}'/"  "${dockerd_conf}"
sudo systemctl daemon-reload
sudo systemctl restart docker
