
# docker image name as defined in default.nix
DOCKER_IMAGE_NAME := $(shell nix --extra-experimental-features nix-command eval -f default.nix dockerImageName)

# build docker image
docker.img: default.nix $(wildcard app/**/*)
	nix-build -A dockerImage --out-link $@

#docker.mkl.img: default.nix $(wildcard app/**/*)
#	# add extra environment variable and --impure flag
#	# to permit installing non-free 'mkl'
#	NIXPKGS_ALLOW_UNFREE=1 nix-build --impure -A dockerImage --out-link $@

# run docker container
docker: docker.img
	docker load < $<
	docker run -p 127.0.0.1:8000:8000/tcp ${DOCKER_IMAGE_NAME}

# run /bin/bash inside docker container
dockerShell: docker.img
	docker load < $<
	docker run -p 127.0.0.1:8000:8000/tcp -i -t ${DOCKER_IMAGE_NAME} /bin/sh

# dump info about docker container
dockerInfo: docker.img
	docker load < $<
	docker image inspect ${DOCKER_IMAGE_NAME}

clean:
	rm -rf ./docker.img ./docker.*.img ./app/__pycache__

# activate nix environment manually
# (use if direnv is not installed)
nixify:
	nix-shell -A devShell

# ------ with nix environment activated ------------

# start web server and reload on file changes
watch:
	uvicorn app.main:app --reload

# run python tests
.PHONY: test
test:
	@python test/test.py


