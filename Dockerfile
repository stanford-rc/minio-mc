FROM golang:1.26-alpine as build

ENV GOPATH /go
ENV CGO_ENABLED 0


RUN apk add -U --no-cache ca-certificates git

# build the checked out tree, including .git, which gen-ldflags.go reads for
# the commit id and time
WORKDIR /go/src/minio-mc
COPY . .
RUN cp LICENSE CREDITS /go/
RUN go build -v -trimpath -tags kqueue -ldflags "$(go run buildscripts/gen-ldflags.go)" -o /go/bin/mc .

FROM scratch

COPY --from=build /go/bin/mc  /usr/bin/mc
COPY --from=build /go/CREDITS /licenses/CREDITS
COPY --from=build /go/LICENSE /licenses/LICENSE
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["mc"]
