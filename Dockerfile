FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 \
      ca-certificates \
      g++ \
      gcc \
      libffi-dev \
      libgdbm3 \
      libgeos-dev \
      libpq-dev \
      libproj-dev \
      libssl-dev \
      libyaml-dev \
      make \
      nodejs \
      patch \
      postgresql \
      procps \
      tzdata \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/etc \
    && echo "install: --no-document\nupdate: --no-document" >> /usr/local/etc/gemrc

RUN set -ex \
    && buildDeps=' \
        autoconf \
        bison \
        dpkg-dev \
        libbz2-dev \
        libgdbm-dev \
        libglib2.0-dev \
        libncurses-dev \
        libreadline-dev \
        libxml2-dev \
        libxslt-dev \
        ruby \
        wget \
        xz-utils \
    ' \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O ruby.tar.xz https://cache.ruby-lang.org/pub/ruby/ruby-2.4.9.tar.xz \
    && mkdir -p /usr/src/ruby \
    && tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1 \
    && rm ruby.tar.xz \
    && cd /usr/src/ruby \
    && autoconf \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure \
        --build="$gnuArch" \
        --disable-install-doc \
        --enable-shared \
    && make -j "$(nproc)" \
    && make install \
    && dpkg-query --show --showformat '${package}\n' \
        | grep -P '^libreadline\d+$' \
        | xargs apt-mark manual \
    && apt-get purge -y --auto-remove $buildDeps \
    && cd / \
    && rm -r /usr/src/ruby \
    && gem update --system \
    && rm -r /root/.gem/

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"

ENV PATH $GEM_HOME/bin:$BUNDLE_PATH/gems/bin:$PATH

RUN adduser safecast --gecos "safecast,,,," \
    && mkdir /src \
    && chown safecast:safecast /src

WORKDIR /src
ADD Gemfile Gemfile.lock .ruby-version /src/
RUN bundle install

USER safecast
CMD [ "bundle", "exec", "rails", "server", "-b", "0.0.0.0" ]
