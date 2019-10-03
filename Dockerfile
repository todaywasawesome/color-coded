#build stage
FROM golang:1.13.1-alpine3.10 AS build-env
ENV GOPROXY=https://gocenter.io 
RUN apk update && apk upgrade && \
    apk add --no-cache git 
ADD . /src
RUN cd /src && go get -d && go build -o myapp

#Add a security vulnerability
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.1/main' >> /etc/apk/repositories
RUN apk add "openssh==6.7_p1-r6" 

# iron/go is the alpine image with only ca-certificates added
FROM alpine
RUN apk add openssh 
WORKDIR /app
COPY --from=build-env /src/myapp /app/
ENTRYPOINT ["./myapp"]
