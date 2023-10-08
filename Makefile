hello:
	echo $(Hello)

intialize:
	go mod download

build:
	go build docker-gs-ping/main.go

run:
	go run docker-gs-ping/main.go
