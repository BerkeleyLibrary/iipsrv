# =============================================================================
# Target: base
#
# The base stage scaffolds elements which are common to building and running
# the application, such as installing ca-certificates, creating the app user,
# and installing runtime system dependencies.

FROM nginx:1 AS base

# This declares that the container intends to listen on port 3000. It doesn't
# actually "expose" the port anywhere -- it is just metadata. It advises tools
# like Traefik about how to treat this container in staging/production.
EXPOSE 80

# ==============================
# Set up shared environment

ENV LOGFILE=/dev/stdout

# ==============================
# Install shared dependencies

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libgomp1 \
      spawn-fcgi

# ==============================
# Copy configuration files

COPY /nginx/nginx.conf /etc/nginx/conf.d/default.conf

# ==============================
# UCB conventional "app" directory

WORKDIR /opt/app

# ==============================
# Set startup command

# Note we don't actually copy this command till later, since
# we're likely to edit it and don't want to bust the cache.
CMD ["./iipsrv-entrypoint.sh"]

# =============================================================================
# Target: development
#
# The development stage builds and installs iipsrv.

FROM base AS development

# ==============================
# Install development tools

RUN apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      build-essential \
      git \
      libtiff-dev \
      libtool \
      pkg-config

# ==============================
# Build and install iipsrv from source

# Clone iipsrv repo
WORKDIR /tmp
RUN git clone --depth 1 --branch iipsrv-1.1 https://github.com/ruven/iipsrv

# Build iipsrv binary
WORKDIR iipsrv
RUN ./autogen.sh && \
    ./configure && \
    make

# Install newly build iipsrv binary
RUN mkdir /iipsrv
RUN cp src/iipsrv.fcgi /iipsrv

# ==============================
# Return to app directory

WORKDIR /opt/app

# ==============================
# Copy test files

COPY test test

# ==============================
# Copy startup script

COPY iipsrv-entrypoint.sh .

# =============================================================================
# Target: production
#
# The production stage extends the base image with the binary built in the
# development stage.

FROM base AS production

COPY --from=development /iipsrv /iipsrv
COPY --from=development /opt/app /opt/app
