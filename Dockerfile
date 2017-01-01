FROM alpine

ENV SS_PASSWD=GdcMCsmlpE.p7G9/GMlEYc7hn3K_6t7c KCPTUN_KEY=KlxauA1Fqxuc.S18N-YHqpp85Wy-9t/N \
	MODE=titan KCP_PORT=2700 SS_PORT=8172 SS_METHOD=chacha20 KCP_METHOD=salsa20 \
	MTU=1470 SNDWND=6400 RCVWND=3072 DSCP=56 PARITYSHARD=5 INTERVAL=13 KEEPALIVE=10 SOCKBUF=4194304 \
	SS_TIMEOUT=30 SS_DNS1=8.8.8.8 SS_DNS2=8.8.4.4
	KERNEL_TYPE=linux-amd64 KCP_VER=20161222

RUN apk add --update openssl ;\
apk add --no-cache --virtual .build-deps build-base curl libtool linux-headers openssl-dev pcre-dev tar xmlto ;\
URL_CONF=https://gist.githubusercontent.com/anonymous/cd6c00f9f82551d842a0b3cfd4c39141/raw/458059b1948e836e6af566265139ff740a55d3e9 ;\
SS_VERSION=`curl "https://github.com/shadowsocks/shadowsocks-libev/releases/latest" | sed -n 's/^.*tag\/\(.*\)".*/\1/p'` ;\
cd /tmp ;\
curl -sSL "https://github.com/shadowsocks/shadowsocks-libev/archive/${SS_VERSION}.tar.gz" | tar xz --strip 1 ;\
./configure --prefix=/usr --disable-documentation ;
make install ;\
runDeps="$(scanelf --needed --nobanner /usr/bin/ss-* | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | xargs -r apk info --installed | sort -u)" ;\
apk add --no-cache --virtual .run-deps $runDeps supervisor ;\
curl -sSL "https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-$KERNEL_TYPE-$KCP_VER.tar.gz" | tar -xf ;\
curl -sSL "${URL_CONF}" -o /supervisord.conf ;\
mv /tmp/server_`char=$KERNEL_TYPE && echo ${char//-/_}` /kt-server ;\
apk del .build-deps ;\
rm -rf /tmp/* /var/cache/apk/*

EXPOSE $KCP_PORT/udp

CMD ["/usr/bin/supervisord"]
