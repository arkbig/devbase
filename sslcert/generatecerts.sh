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

#====================================================================
# begin of ユーザー設定のための環境変数
# 出力先フォルダ - マウントすることで、コンテナ外部に出力される
export CERTS_OUT=${CERTS_OUT:-/certs}
# 自己認証局の設定
export CA_CN=${CA_CN:-"My Test"} # Common Name
ca_cn_filebody=$(echo ca-${CA_CN} | sed -e 's@[ \\/:*?"<>|]@-@g')
export CA_FILEBODY=${CA_FILEBODY:-${ca_cn_filebody}}
export CA_CERT=${CA_CERT:-"${CA_FILEBODY}.cer"} # これをOSに登録する
export CA_KEY=${CA_KEY:-"${CA_FILEBODY}.key"}
export CA_PASS=${CA_PASS-"${CA_FILEBODY}.pass"} # set empty if no password
# CA_SUBJはオプションで、/C=国コード/ST=県/O=組織名/OU=部門名などが指定できます。(/CN=${CA_CN}が自動付与されます)
export CA_SUBJ=${CA_SUBJ:-"/CN=${CA_CN}"}
case "${CA_SUBJ%/CN=*}" in
    "${CA_SUBJ}" ) export CA_SUBJ=${CA_SUBJ}/CN=${CA_CN}
esac
# 自己証明書の設定
export SSL_CN=${SSL_CN:-"dev.test"} # 今の時代あまり意味はない
# 今はSANsが使われる
# 対象のドメインをDNS:〜、対象のIPアドレスをIP:〜で指定する
# DNS:*.exampleのようにTLDだけのワイルドカードは今のブラウザは信用してくれない
export SSL_ADDEXT=${SSL_SANS:-"subjectAltName=DNS:test,DNS:dev.test,DNS:*.dev.test,DNS:localhost,DNS:dev.localhost,DNS:*.dev.localhost,IP:127.0.0.1"}
ssl_cn_filebody=$(echo ssl-${SSL_CN} | sed -e 's@[ \\/:*?"<>|]@-@g')
export SSL_FILEBODY=${SSL_FILEBODY:-${ssl_cn_filebody}}
export SSL_CERT=${SSL_CERT:-"${SSL_FILEBODY}.cer"} # これをサーバーに設定（公開鍵）
export SSL_KEY=${SSL_KEY:-"${SSL_FILEBODY}.key"}   # これもサーバーに設定（秘密鍵）
export SSL_CSR=${SSL_CSR:-"${SSL_FILEBODY}.csr"}
export SSL_PASS=${SSL_PASS-""} # default is no password
export SSL_SERIAL=${SSL_SERIAL:-"${SSL_FILEBODY}.srl"}
# SSL_SUBJはオプションで、/C=国コード/ST=県/O=組織名/OU=部門名などが指定できます。(/CN=${SSL_CN}が自動付与されます)
export SSL_SUBJ=${SSL_SUBJ:-"/CN=${SSL_CN}"}
case "${SSL_SUBJ%/CN=*}" in
    "${SSL_SUBJ}" ) export SSL_SUBJ=${SSL_SUBJ}/CN=${SSL_CN}
esac
# end of ユーザー設定のための環境変数
#--------------------------------------------------------------------

# TODO: 有効期限切れチェック
# if [ -e ${CERTS_OUT}/${CA_CERT} ]; then
#     ca_enddate=`openssl x509 -enddate -noout -in ${CERTS_OUT}/${CA_CERT}`
#     ca_endmonth=`echo "$ca_enddate" | `
# fi

#====================================================================
# begin of 認証局
# 認証局のパスワード作成
if [ -z "${CA_PASS}" ]; then
    echo "<---- Do NOT use CA passphrase ---->"
    ca_passout_arg=
    ca_passin_arg=
elif [ -e "${CERTS_OUT}/${CA_PASS}" ]; then
    echo "<---- Using existing CA Password ${CA_PASS} ---->"
    ca_passout_arg="-aes256 -passout file:${CERTS_OUT}/${CA_PASS}"
    ca_passin_arg="-passin file:${CERTS_OUT}/${CA_PASS}"
else
    echo "<==== Generating new CA Password ${CA_PASS} ====>"
    ca_passout_arg="-aes256 -passout file:${CERTS_OUT}/${CA_PASS}"
    ca_passin_arg="-passin file:${CERTS_OUT}/${CA_PASS}"
    openssl rand -base64 -out "${CERTS_OUT}/${CA_PASS}" 32
    chmod 400 "${CERTS_OUT}/${CA_PASS}"
fi

# 認証局の秘密鍵作成
if [ -e "${CERTS_OUT}/${CA_KEY}" ]; then
    echo "<---- Using existing CA Key ${CA_KEY} ---->"
else
    echo "<==== Generating new CA Key ${CA_KEY} ====>"
    openssl genrsa -out "${CERTS_OUT}/${CA_KEY}" ${ca_passout_arg} 2048
    chmod 400 "${CERTS_OUT}/${CA_KEY}"
fi

# 認証局の自己証明書作成 -- 
if [ -e "${CERTS_OUT}/${CA_CERT}" ]; then
    echo "<---- Using existing CA Cert ${CA_CERT} ---->"
else
    echo "<==== Generating new CA Cert ${CA_CERT} ====>"
    openssl req -new -x509 -days 36500 -key "${CERTS_OUT}/${CA_KEY}" ${ca_passin_arg} -subj "${CA_SUBJ}" -out "${CERTS_OUT}/${CA_CERT}"
fi
# end of 認証局
#--------------------------------------------------------------------

#====================================================================
# begin of 証明書
# 証明書のパスワード作成
if [ -z "${SSL_PASS}" ]; then
    echo "<---- Do NOT use SSL passphrase ---->"
    ssl_passout_arg=
    ssl_passin_arg=
elif [ -e ${CERTS_OUT}/${SSL_PASS} ]; then
    echo "<---- Using existing SSL Password ${SSL_PASS} ---->"
    ssl_passout_arg="-aes256 -passout file:${CERTS_OUT}/${SSL_PASS}"
    ssl_passin_arg="-passin file:${CERTS_OUT}/${SSL_PASS}"
else
    echo "<==== Generating new SSL Password ${SSL_PASS} ====>"
    ssl_passout_arg="-aes256 -passout file:${CERTS_OUT}/${SSL_PASS}"
    ssl_passin_arg="-passin file:${CERTS_OUT}/${SSL_PASS}"
    openssl rand -base64 -out "${CERTS_OUT}/${SSL_PASS}" 32
    chmod 400 "${CERTS_OUT}/${SSL_PASS}"
fi

# 証明書の秘密鍵作成
if [ -e "${CERTS_OUT}/${SSL_KEY}" ]; then
    echo "<---- Using existing SSL Key ${SSL_KEY} ---->"
else
    echo "<==== Generating new SSL Key ${SSL_KEY} ====>"
    openssl genrsa -out "${CERTS_OUT}/${SSL_KEY}" ${ssl_passout_arg} 2048
    chmod 400 "${CERTS_OUT}/${SSL_KEY}"
fi

# 証明書署名要求作成 - 自己証明するので要求は最低限で、証明時に全て指定する
if [ -e "${CERTS_OUT}/${SSL_CSR}" ]; then
    echo "<---- Using existing SSL CSR ${SSL_CSR} ---->"
else
    openssl req -new -key "${CERTS_OUT}/${SSL_KEY}" ${ssl_passin_arg} -subj "${SSL_SUBJ}" -out "${CERTS_OUT}/${SSL_CSR}"
fi

# 証明書署名要求のシリアル番号作成 - 再作成時は自動インクリメントされるのを使う
if [ -e "${CERTS_OUT}/${SSL_SERIAL}" ]; then
    echo "<---- Using existing SSL Serial ${SSL_SERIAL} ---->"
else
    echo "<==== Generating new SSL Serial ${SSL_SERIAL} ====>"
    echo 00 > "${CERTS_OUT}/${SSL_SERIAL}"
fi

# CA署名証明書作成
if [ -e "${CERTS_OUT}/${SSL_CERT}" ]; then
    echo "<---- Using existing SSL CERT ${SSL_CERT} ---->"
else
    echo "<==== Generating new SSL CERT ${SSL_CERT} ====>"
    echo "${SSL_ADDEXT}" | openssl x509 -days 60 -CA "${CERTS_OUT}/${CA_CERT}" -CAkey "${CERTS_OUT}/${CA_KEY}" ${ca_passin_arg} -CAserial "${CERTS_OUT}/${SSL_SERIAL}" -req -in "${CERTS_OUT}/${SSL_CSR}" -out "${CERTS_OUT}/${SSL_CERT}" -extfile -
fi

# 確認 - 余計なのも出力される...-nocert効かない？
openssl x509 -text -in "${CERTS_OUT}/${SSL_CERT}" -noout -nocert -issuer -enddate -subject -ext subjectAltName 
# end of 証明書
#--------------------------------------------------------------------
