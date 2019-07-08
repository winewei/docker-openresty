FROM debian:stretch-slim AS install

ARG OPENRESTY_VERSION 
RUN apt-get update \
    && apt-get install -y --no-install-recommends wget \
       gcc \
       g++ \
       libc-dev \
       make \
       libpcre3 \
       libpcre3-dev \
       openssl \
       libssl1.0 \
       libssl1.0-dev \
       libzip-dev \
       liburi-encode-perl \
       libgetopt-argvfile-perl \
       ca-certificates \
    && set -eux;\
        wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz; \
        tar xf openresty-${OPENRESTY_VERSION}.tar.gz; \
        cd openresty-${OPENRESTY_VERSION}; \
		./configure; \
		make; \
		make install


FROM debian:stretch-slim

COPY --from=install /usr/local/openresty /usr/local/openresty

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
               libssl1.0 \
               libssl1.0-dev \
               liburi-encode-perl \
               libgetopt-argvfile-perl \
               ca-certificates \
               curl \
               gcc \
               make \
               unzip \
               libc-dev \
               wget
ENV PATH="$PATH:/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/luajit/bin"

RUN set -eux; \
           wget https://luarocks.org/releases/luarocks-3.0.4.tar.gz; \
           tar zxpf luarocks-3.0.4.tar.gz; \
           cd luarocks-3.0.4; \
           ./configure; \
           make install \
    && luarocks install luasocket \
    && luarocks install lua-resty-jwt


EXPOSE 80
CMD ["openresty", "-g", "daemon off;"]
