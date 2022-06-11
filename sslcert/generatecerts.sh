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

#====================================================================
# begin of ユーザー設定のための環境変数
# 出力先フォルダ - マウントすることで、コンテナ外部に出力される
: "${CERTS_OUT:=/certs}"
# 自己認証局の設定
: "${CA_CN:="My Test"}" # Common Name
ca_cn_filebody=$(echo "ca-${CA_CN}" | sed -e 's@[ \\/:*?"<>|]@-@g')
: "${CA_FILEBODY:=${ca_cn_filebody}}"
: "${CA_CERT:="${CA_FILEBODY}.cer"}" # これをOSに登録する
: "${CA_KEY:="${CA_FILEBODY}.key"}"
: "${CA_PASS="${CA_FILEBODY}.pass"}" # set empty if no password
# CA_SUBJはオプションで、/C=国コード/ST=県/O=組織名/OU=部門名などが指定できます。(/CN=${CA_CN}が自動付与されます)
: "${CA_SUBJ:="/CN=${CA_CN}"}"
case "${CA_SUBJ%/CN=*}" in
"${CA_SUBJ}") CA_SUBJ=${CA_SUBJ}/CN=${CA_CN} ;;
esac
# 自己証明書の設定
: "${SSL_CN:="dev.test"}" # 今の時代あまり意味はない
# 今はSANsが使われる
# 対象のドメインをDNS:〜、対象のIPアドレスをIP:〜で指定する
# DNS:*.exampleのようにTLDだけのワイルドカードは今のブラウザは信用してくれない
: "${SSL_SANS:="subjectAltName=DNS:test,DNS:dev.test,DNS:*.dev.test,DNS:localhost,DNS:dev.localhost,DNS:*.dev.localhost,IP:127.0.0.1"}"
ssl_cn_filebody=$(echo "ssl-${SSL_CN}" | sed -e 's@[ \\/:*?"<>|]@-@g')
: "${SSL_FILEBODY:=${ssl_cn_filebody}}"
: "${SSL_CERT:="${SSL_FILEBODY}.cer"}" # これをサーバーに設定（公開鍵）
: "${SSL_KEY:="${SSL_FILEBODY}.key"}"  # これもサーバーに設定（秘密鍵）
: "${SSL_CSR:="${SSL_FILEBODY}.csr"}"
: "${SSL_PASS=""}" # default is no password
: "${SSL_SERIAL:="${SSL_FILEBODY}.srl"}"
# SSL_SUBJはオプションで、/C=国コード/ST=県/O=組織名/OU=部門名などが指定できます。(/CN=${SSL_CN}が自動付与されます)
: "${SSL_SUBJ:="/CN=${SSL_CN}"}"
case "${SSL_SUBJ%/CN=*}" in
"${SSL_SUBJ}") : SSL_SUBJ="${SSL_SUBJ}/CN=${SSL_CN}" ;;
esac
# end of ユーザー設定のための環境変数
#--------------------------------------------------------------------

# TODO: 有効期限切れチェック
# if [ -e "${CERTS_OUT}/${CA_CERT}" ]; then
#     ca_enddate=`openssl x509 -enddate -noout -in "${CERTS_OUT}/${CA_CERT}"`
#     ca_endmonth=`echo "$ca_enddate" | `
# fi

#====================================================================
# begin of 認証局
# 認証局のパスワード作成
if [ -z "${CA_PASS}" ]; then
    echo "<---- Do NOT use CA passphrase ---->"
    ca_passout_args=
    ca_passin_args=
elif [ -e "${CERTS_OUT}/${CA_PASS}" ]; then
    echo "<---- Using existing CA Password ${CA_PASS} ---->"
    ca_passout_args="-aes256 -passout file:${CERTS_OUT}/${CA_PASS}"
    ca_passin_args="-passin file:${CERTS_OUT}/${CA_PASS}"
else
    echo "<==== Generating new CA Password ${CA_PASS} ====>"
    ca_passout_args="-aes256 -passout file:${CERTS_OUT}/${CA_PASS}"
    ca_passin_args="-passin file:${CERTS_OUT}/${CA_PASS}"
    openssl rand -base64 -out "${CERTS_OUT}/${CA_PASS}" 32
    chmod 400 "${CERTS_OUT}/${CA_PASS}"
fi

# 認証局の秘密鍵作成
if [ -e "${CERTS_OUT}/${CA_KEY}" ]; then
    echo "<---- Using existing CA Key ${CA_KEY} ---->"
else
    echo "<==== Generating new CA Key ${CA_KEY} ====>"
    # shellcheck disable=SC2086
    openssl genrsa -out "${CERTS_OUT}/${CA_KEY}" ${ca_passout_args} 2048
    chmod 400 "${CERTS_OUT}/${CA_KEY}"
fi

# 認証局の自己証明書作成 --
if [ -e "${CERTS_OUT}/${CA_CERT}" ]; then
    echo "<---- Using existing CA Cert ${CA_CERT} ---->"
else
    echo "<==== Generating new CA Cert ${CA_CERT} ====>"
    # shellcheck disable=SC2086
    openssl req -new -x509 -days 36500 -key "${CERTS_OUT}/${CA_KEY}" ${ca_passin_args} -subj "${CA_SUBJ}" -out "${CERTS_OUT}/${CA_CERT}"
fi
# end of 認証局
#--------------------------------------------------------------------

#====================================================================
# begin of 証明書
# 証明書のパスワード作成
if [ -z "${SSL_PASS}" ]; then
    echo "<---- Do NOT use SSL passphrase ---->"
    ssl_passout_args=
    ssl_passin_args=
elif [ -e "${CERTS_OUT}/${SSL_PASS}" ]; then
    echo "<---- Using existing SSL Password ${SSL_PASS} ---->"
    ssl_passout_args="-aes256 -passout file:${CERTS_OUT}/${SSL_PASS}"
    ssl_passin_args="-passin file:${CERTS_OUT}/${SSL_PASS}"
else
    echo "<==== Generating new SSL Password ${SSL_PASS} ====>"
    ssl_passout_args="-aes256 -passout file:${CERTS_OUT}/${SSL_PASS}"
    ssl_passin_args="-passin file:${CERTS_OUT}/${SSL_PASS}"
    openssl rand -base64 -out "${CERTS_OUT}/${SSL_PASS}" 32
    chmod 400 "${CERTS_OUT}/${SSL_PASS}"
fi

# 証明書の秘密鍵作成
if [ -e "${CERTS_OUT}/${SSL_KEY}" ]; then
    echo "<---- Using existing SSL Key ${SSL_KEY} ---->"
else
    echo "<==== Generating new SSL Key ${SSL_KEY} ====>"
    # shellcheck disable=SC2086
    openssl genrsa -out "${CERTS_OUT}/${SSL_KEY}" ${ssl_passout_args} 2048
    chmod 400 "${CERTS_OUT}/${SSL_KEY}"
fi

# 証明書署名要求作成 - 自己証明するので要求は最低限で、証明時に全て指定する
if [ -e "${CERTS_OUT}/${SSL_CSR}" ]; then
    echo "<---- Using existing SSL CSR ${SSL_CSR} ---->"
else
    # shellcheck disable=SC2086
    openssl req -new -key "${CERTS_OUT}/${SSL_KEY}" ${ssl_passin_args} -subj "${SSL_SUBJ}" -out "${CERTS_OUT}/${SSL_CSR}"
fi

# 証明書署名要求のシリアル番号作成 - 再作成時は自動インクリメントされるのを使う
if [ -e "${CERTS_OUT}/${SSL_SERIAL}" ]; then
    echo "<---- Using existing SSL Serial ${SSL_SERIAL} ---->"
else
    echo "<==== Generating new SSL Serial ${SSL_SERIAL} ====>"
    echo 00 >"${CERTS_OUT}/${SSL_SERIAL}"
fi

# CA署名証明書作成
if [ -e "${CERTS_OUT}/${SSL_CERT}" ]; then
    echo "<---- Using existing SSL CERT ${SSL_CERT} ---->"
else
    echo "<==== Generating new SSL CERT ${SSL_CERT} ====>"
    # shellcheck disable=SC2086
    echo "${SSL_SANS}" | openssl x509 -days 60 -CA "${CERTS_OUT}/${CA_CERT}" -CAkey "${CERTS_OUT}/${CA_KEY}" ${ca_passin_args} -CAserial "${CERTS_OUT}/${SSL_SERIAL}" -req -in "${CERTS_OUT}/${SSL_CSR}" -out "${CERTS_OUT}/${SSL_CERT}" -extfile -
fi

# 確認 - 余計なのも出力される...-nocert効かない？
openssl x509 -text -in "${CERTS_OUT}/${SSL_CERT}" -noout -nocert -issuer -enddate -subject -ext subjectAltName
# end of 証明書
#--------------------------------------------------------------------
