FROM golang:1.22.4-alpine3.20
LABEL maintainer="Raphael Ebner"
LABEL org.opencontainers.image.source="https://github.com/OSS-App-Forks/traefik-ssl-certificate-exporter"
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
# Expecting to copy go.mod and if present go.sum.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./
RUN go build


FROM alpine:3.20
LABEL maintainer="Raphael Ebner"
LABEL org.opencontainers.image.source="https://github.com/OSS-App-Forks/traefik-ssl-certificate-exporter"
WORKDIR /app

ENV CRON_TIME="* * * * *"
ENV CERT_OWNER_ID="0"
ENV CERT_GROUP_ID="0"
ENV ON_START=1

COPY --from=0 /app/traefik-ssl-certificate-exporter ./
RUN apk update && apk add bash
COPY entrypoint.sh ./
RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
