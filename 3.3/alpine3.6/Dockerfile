#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "haxe update.hxml"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.6

# ensure local haxe is preferred over distribution haxe
ENV PATH /usr/local/bin:$PATH

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies are installed later
RUN apk add --no-cache ca-certificates

ENV NEKO_VERSION 2.2.0
ENV HAXE_VERSION 3.3.0-rc.1

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		libressl \
		tar \
		git \
	\
	&& wget -O neko.tar.gz "https://github.com/HaxeFoundation/neko/archive/v2-2-0/neko-2.2.0.tar.gz" \
	&& echo "cf101ca05db6cb673504efe217d8ed7ab5638f30e12c5e3095f06fa0d43f64e3 *neko.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/src/neko \
	&& tar -xC /usr/src/neko --strip-components=1 -f neko.tar.gz \
	&& rm neko.tar.gz \
	&& apk add --no-cache --virtual .build-deps \
		apache2-dev \
		cmake \
		gc-dev \
		gcc \
		gtk+2.0-dev \
		libc-dev \
		linux-headers \
		mariadb-dev \
		mbedtls-dev \
		ninja \
		sqlite-dev \
	&& cd /usr/src/neko \
	&& cmake -GNinja -DNEKO_JIT_DISABLE=ON -DRELOCATABLE=OFF -DRUN_LDCONFIG=OFF . \
	&& ninja \
	&& ninja install \
	\
	&& git clone --recursive --depth 1 --branch 3.3.0-rc1 "https://github.com/HaxeFoundation/haxe.git" /usr/src/haxe \
	&& apk add --no-cache --virtual .build-deps \
		camlp4 \
		ocaml \
		pcre-dev \
		zlib-dev \
		make \
	&& cd /usr/src/haxe \
	&& make OCAMLOPT=ocamlopt.opt \
	&& make install INSTALL_DIR=/usr/local \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .python-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .fetch-deps \
	\
	&& cd / && haxelib setup /usr/local/lib/haxe/lib

CMD ["haxe"]
