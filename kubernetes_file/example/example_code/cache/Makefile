.PHONY: build
build:
	GOOS=linux GOARCH=arm64 go build -o cache .
	docker build --rm -t yuexclusive/cache:latest .
	docker push yuexclusive/cache:latest