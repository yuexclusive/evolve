.PHONY: build
build:
	docker build -t yuexclusive/website:latest . --no-cache

.PHONY: push 
push: build
	docker push yuexclusive/website