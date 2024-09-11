FROM --platform=linux/amd64 golang:1.23.1-alpine AS build
RUN apk --update add curl gcc git musl-dev util-linux-dev

WORKDIR /app
RUN mkdir -p bin

COPY . .
RUN go install golang.org/x/tools/cmd/stringer@latest
RUN go generate ./...

WORKDIR /app/cmd/atlas
RUN go generate ./...
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -trimpath -ldflags "-extldflags '-static' -s -w -X ariga.io/atlas/cmd/atlas/internal/cmdapi.flavor=custom-build" -o /app/bin/atlas .
RUN chmod +x /app/bin/atlas


FROM alpine
COPY --from=build /app/bin/atlas /atlas
