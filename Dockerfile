FROM golang:1.25.14-alpine3.24 AS build

RUN apk --update add \
    gcc \
    musl-dev \
    git

RUN mkdir /build

COPY . /build

WORKDIR /build

RUN go build -ldflags "-s -w -X github.com/bitmagnet-io/bitmagnet/internal/version.GitTag=$(git describe --tags --always --dirty)"

FROM alpine:3.24

RUN apk --update add \
    curl \
    iproute2-ss \
    && rm -rf /var/cache/apk/*

COPY --from=build /build/bitmagnet /usr/bin/bitmagnet

# r053 fork addition: bitmagnet has no _FILE convention for secrets, so wrap
# its entrypoint to read the Postgres password from a mounted Docker secret
# (mirrors the same pattern used by grafana/ and redis/ in the r053 repo).
# Plain COPY + chmod, not `COPY --chmod` - the r053 CI runner's `docker
# build` doesn't have BuildKit enabled (classic builder), unlike `docker
# compose build` which defaults to buildx.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
