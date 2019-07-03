#build stage
FROM golang:1.10.3-alpine AS build-env
ENV GOPROXY=https://gocenter.io 
ADD . /src
RUN cd /src && go build -o myapp

# iron/go is the alpine image with only ca-certificates added
FROM alpine
RUN apk add openssh 
WORKDIR /app
COPY --from=build-env /src/myapp /app/
ENTRYPOINT ["./myapp"]
