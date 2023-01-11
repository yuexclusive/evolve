.PHONY: build
build:
	GOOS=linux GOARCH=arm64 go build -o test .
	docker build --rm -t yuexclusive/test:latest .
	docker push yuexclusive/test:latest
