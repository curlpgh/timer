# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian
# instead of Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20230202-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.14.3-erlang-25.2.3-debian-bullseye-20230202-slim
#
# To build for multiple platforms and push to Docker Hub repository

# On Linux:
# sudo docker tag timer:0.1.0 pghcc/timer_amd64:0.1.0
# sudo docker push pghcc/timer_amd64:0.1.0

# On Mac:
# docker tag timer:0.1.0 pghcc/timer_arm64:0.1.0
# docker push pghcc/timer_arm64:0.1.0

#
ARG ELIXIR_VERSION=1.14.3
ARG OTP_VERSION=25.2.3
ARG DEBIAN_VERSION=bullseye-20230202-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl ca-certificates gnupg \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Install nodejs. Reference: https://github.com/nodesource/distributions
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ARG NODE_MAJOR=20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install nodejs -y

# prepare build dir
WORKDIR /app

# set build ENV
ENV MIX_ENV="prod"

# Workaround QEMU JIT issue building AMD64 on ARM64
# ENV ERL_FLAGS="+JPperf true"

# install hex + rebar
RUN mix local.hex --force
RUN mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

WORKDIR /app/assets
RUN npm install
RUN npx update-browserslist-db@latest
WORKDIR /app
RUN npm run deploy --prefix ./assets

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel

RUN mix release timer

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales sqlite3 imagemagick inotify-tools \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"

RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/timer ./

# Initialize the docker volumes
RUN mkdir -p /var/lib/timer/db
RUN mkdir -p /var/lib/timer/uploads
RUN mkdir -p /var/lib/timer/error_logs

# Create sym link for uploads directory. 
# Note that File.cwd!() returns /app/bin for Docker conatiner.
RUN ln -s /var/lib/timer/uploads /app/bin/uploads

# chown stuff
RUN chown -R nobody: /var/lib/timer
RUN chown -R nobody: /app/bin/uploads

USER nobody

# Migrate and seed the database
RUN /app/bin/timer eval "Timer.Release.seed"

CMD ["/app/bin/server"]
