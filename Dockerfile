FROM python:3.8-alpine3.12

ARG JEMALLOC_VERSION=5.2.1
WORKDIR /tmp
COPY . .

# Install packages
RUN set -x \
    && apk update \
    && echo "http://dl-8.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "http://dl-8.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    # install default packages
    && apk add --no-cache \
        tzdata \
        ca-certificates \
        curl \
        flac \
        sox \
        libuv \
        ffmpeg \
        uchardet \
        # dependencies for pillow
        freetype \
        lcms2 \
        libimagequant \
        libjpeg-turbo \
        libwebp \
        libxcb \
        openjpeg \
        tiff \
        zlib \
    # install (temp) build packages
    && apk add --no-cache --virtual .build-deps \
        build-base \
        libsndfile-dev \
        taglib-dev \
        gcc \
        musl-dev \
        freetype-dev \
        libpng-dev \
        libressl-dev \
        fribidi-dev \
        harfbuzz-dev \
        jpeg-dev \
        lcms2-dev \
        openjpeg-dev \
        tcl-dev \
        tiff-dev \
        tk-dev \
        zlib-dev \
        libuv-dev \
        libffi-dev \
        uchardet-dev \
    # setup jemalloc
    && curl -L -f -s "https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2" \
            | tar -xjf - -C /tmp \
        && cd /tmp/jemalloc-${JEMALLOC_VERSION} \
        && ./configure \
        && make \
        && make install \
        && cd /tmp \
    # make sure optional packages are installed
    && pip install uvloop cchardet aiodns brotlipy \
    # install music assistant
    && pip install . \
    # cleanup build files
    && apk del .build-deps \
    && rm -rf /tmp/*

ENV DEBUG=false
EXPOSE 8095/tcp

VOLUME [ "/data" ]

ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so
ENTRYPOINT ["mass", "--config", "/data"]