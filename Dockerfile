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
# Install dependencies

# TODO: does production need all of these?
RUN apt-get update && \
    apt-get install -y \
      autoconf \
      build-essential \
      git \
      libtiff-dev \
      libtool \
      pkg-config \
      spawn-fcgi

# =============================================================================
# Target: development
#
# The development stage builds iipsrv and installs configuration files.

FROM base AS development

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

# ==============================
# Copy configuration files

COPY /nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY iipsrv-entrypoint.sh /

CMD /iipsrv-entrypoint.sh

# =============================================================================
# Target: production
#
# The production stage extends the base image with the application and gemset
# built in the development stage. It includes runtime dependencies but not
# heavyweight build dependencies.

FROM base AS production

COPY --from=development /iipsrv /iipsrv
COPY --from=development /etc/nginx /etc/nginx
COPY --from=development /iipsrv-entrypoint.sh /iipsrv-entrypoint.sh

CMD /iipsrv-entrypoint.sh
