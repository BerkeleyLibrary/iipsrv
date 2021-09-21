# =============================================================================
# Target: base
#
# The base stage scaffolds elements which are common to building and running
# the application, such as installing ca-certificates, creating the app user,
# and installing runtime system dependencies.

FROM nginx:1.18.0 AS base

# This declares that the container intends to listen on port 3000. It doesn't
# actually "expose" the port anywhere -- it is just metadata. It advises tools
# like Traefik about how to treat this container in staging/production.
EXPOSE 80

# ==============================
# Set up shared environment

ENV LOGFILE=/dev/stdout

# ==============================
# Install dependencies

# ==============================
# Copy configuration files and startup script

COPY /nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY iipsrv-entrypoint.sh /

# ==============================
# Copy test files

COPY iipsrv-test /iipsrv-test

# ==============================
# Set startup command

CMD /iipsrv-entrypoint.sh

# ==============================
# Install shared dependencies

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libgomp1 \
      spawn-fcgi

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
# Build iipsrv from source

RUN git clone --depth 1 --branch iipsrv-1.1 https://github.com/ruven/iipsrv /tmp/iipsrv

WORKDIR /tmp/iipsrv

RUN ./autogen.sh && \
    ./configure && \
    make

# ==============================
# Install newly build iipsrv binary

RUN mkdir /iipsrv
RUN cp /tmp/iipsrv/src/iipsrv.fcgi /iipsrv

# =============================================================================
# Target: production
#
# The production stage extends the base image with the binary built in the
# development stage.

FROM base AS production

COPY --from=development /iipsrv /iipsrv
