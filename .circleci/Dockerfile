FROM public.ecr.aws/amazonlinux/amazonlinux:2

RUN /usr/bin/amazon-linux-extras install -y \
  postgresql11 \
  python3.8 \
  ruby2.6
RUN /usr/bin/yum install -y \
  gcc \
  gcc-c++ \
  git \
  make \
  postgresql-devel \
  rpm-build \
  ruby-devel \
  rubygem-io-console \
  shadow-utils \
  sudo \
  util-linux \
  xorg-x11-server-Xvfb \
  zlib-devel
RUN curl -sSL -o /tmp/dockerize.tgz https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-amd64-v0.6.1.tar.gz && \
  tar -xzf /tmp/dockerize.tgz -C /usr/local/bin && \
  rm /tmp/dockerize.tgz
RUN curl -sLO https://rpm.nodesource.com/setup_14.x && \
  bash setup_14.x && \
  rm setup_14.x && \
  yum install -y nodejs
RUN curl -sLO https://dl.yarnpkg.com/rpm/yarn.repo && \
  mv yarn.repo /etc/yum.repos.d/ && \
  yum install -y yarn
ADD ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN rm /usr/bin/python && ln -s /usr/bin/python3.8 /usr/bin/python

RUN /usr/sbin/adduser -m circleci&& usermod -aG wheel circleci
RUN /usr/bin/sed -i -e "s/^# %wheel/%wheel/" /etc/sudoers

USER circleci
ENV PATH /home/circleci/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN sudo /usr/bin/pip3.8 install --upgrade pip
RUN sudo /usr/local/bin/pip3.8 install awscli awsebcli

ENTRYPOINT ["/docker-entrypoint.sh"]
