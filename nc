FROM alpine

ENV SS_PASSWD=GdcMCsmlpE.p7G9/GMlEYc7hn3K_6t7c KCPTUN_KEY=KlxauA1Fqxuc.S18N-YHqpp85Wy-9t/N \
	MODE=manual KCP_PORT=2700 SS_PORT=8172 SS_METHOD=chacha20-ietf-poly1305 KCP_METHOD=salsa20 \
	MTU=1470 SNDWND=6400 RCVWND=3072 DSCP=56 DATASHARD=10 PARITYSHARD=2 INTERVAL=13 KEEPALIVE=5 SOCKBUF=33554432 SCAVENGE_TTL=10 \
	SS_TIMEOUT=20 SS_DNS1=8.8.8.8 SS_DNS2=8.8.4.4 \
	KERNEL_TYPE=linux-amd64 KCP_VER=20170525

RUN apk add --update openssl ;\
apk add --no-cache libcrypto1.0 libev libsodium mbedtls pcre udns ;\
apk add --no-cache --virtual .build-deps autoconf automake build-base curl gettext-dev libev-dev libsodium-dev libtool linux-headers mbedtls-dev openssl-dev pcre-dev tar udns-dev ;\
URL_CONF=https://gist.githubusercontent.com/anonymous/76f94ac48a90c2bd49f1543d0de161ab/raw/8f359f90712e5e6843df683cc05bf6e720b36220 ;\
SS_VERSION=`curl "https://github.com/shadowsocks/shadowsocks-libev/releases/latest" | sed -n 's/^.*tag\/\(.*\)".*/\1/p'` ;\
cd /tmp ;\
curl -sSL "https://github.com/shadowsocks/shadowsocks-libev/archive/${SS_VERSION}.tar.gz" | tar xz --strip 1 ;\
curl -sSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset ;\
curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork ;\
curl -sSL https://github.com/shadowsocks/libbloom/archive/master.tar.gz | tar xz --strip 1 -C libbloom ;\
./autogen.sh && ./configure --prefix=/usr --disable-documentation && make install ;\
runDeps="$(scanelf --needed --nobanner /usr/bin/ss-* | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | xargs -r apk info --installed | sort -u)" ;\
apk add --no-cache --virtual .run-deps $runDeps supervisor ;\
curl -sSL "https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-$KERNEL_TYPE-$KCP_VER.tar.gz" | tar xz ;\
curl -sSL "${URL_CONF}" -o /supervisord.conf ;\
mv /tmp/server_`char=$KERNEL_TYPE && echo ${char//-/_}` /kt-server ;\
apk del .build-deps ;\
rm -rf /tmp/* /var/cache/apk/*

EXPOSE $KCP_PORT/udp

CMD ["/usr/bin/supervisord"]
