.PHONY: clean
clean:
	docker images -f "dangling=true" | grep -v kindest | awk 'NR!=1{print $$3}' | xargs docker rmi


.PHONY: build
build:
	docker build -t evolve_alpine .
	make clean