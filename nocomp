FROM alpine

ENV SS_PASSWD=GdcMCsmlpE.p7G9/GMlEYc7hn3K_6t7c KCPTUN_KEY=KlxauA1Fqxuc.S18N-YHqpp85Wy-9t/N \
	MODE=titan KCP_PORT=2700 SS_PORT=8172 SS_METHOD=chacha20 KCP_METHOD=salsa20 \
	MTU=1470 SNDWND=6400 RCVWND=3072 DSCP=56 DATASHARD=10 PARITYSHARD=5 INTERVAL=13 KEEPALIVE=10 SOCKBUF=4194304 \
	SS_TIMEOUT=20 SS_DNS1=8.8.8.8 SS_DNS2=8.8.4.4 \
	KERNEL_TYPE=linux-amd64 KCP_VER=20170322

RUN apk add --update openssl ;\
apk add --no-cache --virtual .build-deps autoconf automake build-base curl gettext-dev libev-dev libsodium-dev libtool linux-headers openssl-dev pcre-dev tar udns-dev ;\
URL_CONF=https://gist.githubusercontent.com/anonymous/08b40d7038ebcc6dc319f04afea2cd90/raw/86f453247ba01cc2fb52be19e4762d1e74f74d93 ;\
SS_VERSION=`curl "https://github.com/shadowsocks/shadowsocks-libev/releases/latest" | sed -n 's/^.*tag\/\(.*\)".*/\1/p'` ;\
cd /tmp ;\
curl -sSL "https://github.com/shadowsocks/shadowsocks-libev/archive/${SS_VERSION}.tar.gz" | tar xz --strip 1 ;\
curl -sSL https://github.com/shadowsocks/ipset/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libipset ;\
curl -sSL https://github.com/shadowsocks/libcork/archive/shadowsocks.tar.gz | tar xz --strip 1 -C libcork ;\
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
