FROM public.ecr.aws/amazonlinux/amazonlinux:2023

RUN yum install -y \
  tar \
  gzip \
  gcc \
  libyaml-devel \
  openssl-devel \
  zlib-devel \
  nodejs-npm \
  xorg-x11-server-Xvfb \
  git

# RUN /usr/bin/amazon-linux-extras install -y \
#   postgresql11 \
#   python3.8

# RUN /usr/bin/yum install -y deltarpm && \
#   /usr/bin/yum update -y && \
#   /usr/bin/yum install -y \
#     gcc \
#     gcc-c++ \
#     git \
#     libffi-devel \
#     libpq-devel \
#     make \
#     openssl-devel \
#     python38-devel \
#     readline-devel \
#     rpm-build \
#     shadow-utils \
#     sudo \
#     util-linux \
#     xorg-x11-server-Xvfb \
#     zlib-devel

RUN curl -sSL -o /tmp/dockerize.tgz https://github.com/jwilder/dockerize/releases/download/v0.9.3/dockerize-linux-amd64-v0.9.3.tar.gz && \
  tar -xzf /tmp/dockerize.tgz -C /usr/local/bin && \
  rm /tmp/dockerize.tgz

RUN curl -sSL -o /tmp/ruby-3.4.2.tar.gz https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.2.tar.gz \
  && tar -xzf /tmp/ruby-3.4.2.tar.gz \
  && cd ruby-3.4.2 \
  && ./configure \
  && make -j4 \
  && make install \
  && cd .. \
  && rm -rf ruby-3.4.2 /tmp/ruby-3.4.2.tar.gz

# RUN curl -sLO https://rpm.nodesource.com/setup_14.x && \
#   bash setup_14.x && \
#   rm setup_14.x && \
#   yum install -y nodejs

# RUN curl -sLO https://dl.yarnpkg.com/rpm/yarn.repo && \
#   mv yarn.repo /etc/yum.repos.d/ && \
#   yum install -y yarn

ADD ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# RUN python3.8 -m pip install cryptography==3.3.2 awscli awsebcli

# RUN /usr/sbin/adduser -m circleci&& usermod -aG wheel circleci
# RUN /usr/bin/sed -i -e "s/^# %wheel/%wheel/" /etc/sudoers

# USER circleci

# TODO move these to top dockerfile area
RUN yum install -y \
  postgresql-devel \
  g++ \
  xz \
  postgresql17 \
  python3 \
  python3-pip \
  python3-setuptools

RUN pip install awsebcli

ENTRYPOINT ["/docker-entrypoint.sh"]
