init:
	docker run --rm -it --privileged -w /root -v `pwd`:/root -v /var/run/docker.sock:/var/run/docker.sock yuexclusive/dood nu -c "source packup.nu; packup init"
	# nu -c "source packup.nu; packup init"

packup:
	docker run --rm -it --privileged -w /root -v `pwd`:/root -v /var/run/docker.sock:/var/run/docker.sock yuexclusive/dood nu -c "source packup.nu; packup exec"
	# nu -c "source packup.nu; packup exec"
