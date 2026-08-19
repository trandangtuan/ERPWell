FROM ruby:2.5.1-stretch

ENV BUNDLE_PATH=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g; s|security.debian.org/debian-security|archive.debian.org/debian-security|g; /stretch-updates/d' /etc/apt/sources.list \
  && apt-get update -o Acquire::Check-Valid-Until=false \
  && apt-get install -y --allow-unauthenticated --no-install-recommends \
    build-essential \
    curl \
    default-libmysqlclient-dev \
    gnupg \
    imagemagick \
    less \
    mysql-client \
    shared-mime-info \
    xz-utils \
  && curl -fsSL https://nodejs.org/dist/v10.24.1/node-v10.24.1-linux-x64.tar.xz -o /tmp/node.tar.xz \
  && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
  && rm /tmp/node.tar.xz \
  && npm install -g yarn@1.22.22 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . .
COPY docker/entrypoint.sh /usr/bin/parkviet-entrypoint
RUN chmod +x /usr/bin/parkviet-entrypoint

EXPOSE 3000

ENTRYPOINT ["parkviet-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
