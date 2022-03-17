FROM golang:1.18.0-alpine as builder
ARG HASH
WORKDIR /app
RUN apk add --no-cache git

COPY go.mod go.sum ./
RUN go mod vendor -v
RUN go get github.com/GeertJohan/go.rice
RUN go install -v github.com/GeertJohan/go.rice/rice@latest

COPY . .
RUN rice embed-go -v -i .
RUN CGO_ENABLED=0 go build -mod=vendor -ldflags "-X main.githash=$HASH"

FROM scratch
COPY --from=builder /app/filebin /usr/bin/filebin
ENTRYPOINT [ "/usr/bin/filebin" ]
