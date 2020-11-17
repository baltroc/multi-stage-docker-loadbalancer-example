FROM golang:1.7.3
WORKDIR /go/src/github.com/alexellis/href-counter/
COPY ./app.go .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o app .


FROM busybox
COPY --from=0 /go/src/github.com/alexellis/href-counter/app /home/
CMD /home/app
