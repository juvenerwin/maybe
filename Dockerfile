# syntax = docker/dockerfile:1
ARG RUBY_VERSION=3.4.4
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base
WORKDIR /rails

# CONA builds run as a single user: apt stays root, and chown/chgrp to other users must not fail
RUN echo 'APT::Sandbox::User "root";' > /etc/apt/apt.conf.d/00-cona-single-user
RUN mv /usr/bin/chown /usr/bin/chown.real && mv /usr/bin/chgrp /usr/bin/chgrp.real && \
    printf '#!/bin/sh\n/usr/bin/chown.real "$@" 2>/dev/null || true\n' > /usr/bin/chown && \
    printf '#!/bin/sh\n/usr/bin/chgrp.real "$@" 2>/dev/null || true\n' > /usr/bin/chgrp && \
    chmod 0755 /usr/bin/chown /usr/bin/chgrp

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client libyaml-0-2

ARG BUILD_COMMIT_SHA
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    BUILD_COMMIT_SHA=${BUILD_COMMIT_SHA}

FROM base AS build
RUN apt-get install --no-install-recommends -y build-essential libpq-dev git pkg-config libyaml-dev
COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install
RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
RUN bundle exec bootsnap precompile --gemfile -j 0
COPY . .
RUN bundle exec bootsnap precompile -j 0 app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

FROM base
RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]
