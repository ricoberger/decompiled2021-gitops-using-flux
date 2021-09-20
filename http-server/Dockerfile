FROM golang:1.15.6-alpine3.12 as build
WORKDIR /server
COPY http-server/go.mod  ./
RUN go mod download
COPY http-server/main.go .
RUN go build -o server .

FROM alpine:3.12.0
RUN apk update && apk add --no-cache ca-certificates
RUN mkdir /server
COPY --from=build /server/server /server
WORKDIR /server
USER nobody
ENTRYPOINT  [ "/server/server" ]
