FROM alpine:3.4

ENV SS_PASSWD=GdcMCsmlpE.p7G9/GMlEYc7hn3K_6t7c KCPTUN_KEY=KlxauA1Fqxuc.S18N-YHqpp85Wy-9t/N \
	MODE=titan KCP_PORT=2700 SS_PORT=8172 SS_METHOD=chacha20 KCP_METHOD=salsa20 \
	MTU=1470 SNDWND=6400 RCVWND=3072 DSCP=56 PARITYSHARD=5 INTERVAL=13 KEEPALIVE=10 SOCKBUF=4194304 \
	KERNEL_TYPE=linux-amd64 KCP_VER=20161222

RUN apk add --update openssl ;\
apk add --no-cache build-base curl linux-headers openssl-dev tar supervisor ;\
URL_CONF=https://gist.github.com/anonymous/fae198e0090b47ad45b9901e9cc1e66b/raw/ea79cd464b6ba8281f09f7a60fad5702850282ac/gistfile1.txt ;\
SS_VERSION=`curl "https://github.com/shadowsocks/shadowsocks-libev/releases/latest" | sed -n 's/^.*tag\/\(.*\)".*/\1/p'` ;\
mkdir -p /tmp_$KCP_VER ;\
cd /tmp_$KCP_VER ;\
curl -SL "https://github.com/shadowsocks/shadowsocks-libev/archive/${SS_VERSION}.tar.gz" -o ss.tar.gz && tar -xf ss.tar.gz --strip-components=1 ;\
curl -SL "https://github.com/xtaci/kcptun/releases/download/v$KCP_VER/kcptun-$KERNEL_TYPE-$KCP_VER.tar.gz" -o kcptun.tar.gz && tar -xf kcptun.tar.gz ;\
curl -SL "${URL_CONF}" -o /supervisord.conf ;\
mv /tmp_$KCP_VER/server_`char=$KERNEL_TYPE && echo ${char//-/_}` /kt-server ;\
./configure && make ;\
cd ./src ;\
make install ;\
rm -rf /tmp_$KCP_VER /var/cache/apk/* ;\
apk del build-base curl linux-headers openssl-dev tar

EXPOSE $KCP_PORT/udp

CMD ["/usr/bin/supervisord"]
