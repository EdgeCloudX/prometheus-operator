FROM golang:1.19-alpine AS builder

ADD ../.. /go/src/EdgeCloudX/prometheus-operator
WORKDIR /go/src/EdgeCloudX/prometheus-operator
# RUN apk update && apk --no-cache add make && make config-reloader
RUN GOOS=linux CGO_ENABLED=0 go build -mod=vendor -ldflags="-s -X github.com/coreos/prometheus-operator/pkg/version.Version=v0.44.1" -o prometheus-config-reloader cmd/prometheus-config-reloader/main.go

FROM quay.io/prometheus/busybox:latest
COPY --from=builder /go/src/EdgeCloudX/prometheus-operator/prometheus-config-reloader /bin/prometheus-config-reloader

USER nobody

ENTRYPOINT ["/bin/prometheus-config-reloader"]
