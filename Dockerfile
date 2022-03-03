FROM golang:1.12.5 as builder

WORKDIR /go/src/app
COPY src .
RUN CGO_ENABLED=0 go build -o bin .

FROM alpine:latest as certs
RUN apk --update add ca-certificates

FROM scratch
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/src/app/bin /bin

# Define hello env variable
ENV HELLO="This is HELLO ENV VAR"

EXPOSE 8080
ENTRYPOINT ["/bin"]
