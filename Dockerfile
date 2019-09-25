#build stage
FROM golang:1.10.3-alpine AS build-env
ENV GOPROXY=https://gocenter.io 
ADD . /src
RUN cd /src && go build -o myapp

#Add a security vulnerability
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.1/main' >> /etc/apk/repositories
RUN apk add "openssh==6.7_p1-r6"

# iron/go is the alpine image with only ca-certificates added
FROM alpine
RUN apk add openssh 
WORKDIR /app
COPY --from=build-env /src/myapp /app/
ENTRYPOINT ["./myapp"]
