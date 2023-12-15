init:
	if ! test -f packup.nu; then docker create --name my_dood yuexclusive/dood:latest; docker cp my_dood:/work/packup.nu packup.nu; docker rm my_dood; fi
	docker run --rm -it --privileged -w /work -v `pwd`:/work -v /var/run/docker.sock:/var/run/docker.sock yuexclusive/dood nu -c "source packup.nu; packup init"
	# nu -c "source packup.nu; packup init"

packup:
	docker run --rm -it --privileged -w /work -v `pwd`:/work -v /var/run/docker.sock:/var/run/docker.sock yuexclusive/dood nu -c "source packup.nu; packup exec"
	# nu -c "source packup.nu; packup exec"
