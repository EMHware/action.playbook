FROM golang:alpine as builder

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
COPY . .

RUN go mod download

# Build the application
RUN go build -o main

FROM cytopia/ansible:2.13 as production
#FROM cytopia/ansible:latest as production

ENV PIP_ROOT_USER_ACTION=ignore
RUN apk add py3-pip mysql-client
RUN pip3 install boto3 botocore PyMySQL

# Copy binary from build to main folder
COPY --from=builder /build/main /usr/local/bin

# Run as root
USER root

# Command to run when starting the container
CMD ["main"]
