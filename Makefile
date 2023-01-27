
image:
	nix-build -A dockerImage

image.mlk:
	# for add extra environment variable and --impure flag
	# to permit installing non-free 'mkl'
	NIXPKGS_ALLOW_UNFREE=1 nix-build --impure -A dockerImage

test: image
	#$(nix-build -A dockerImage) | docker load
	docker load < result
	docker run -p 127.0.0.1:8000:8000/tcp pyhello

shell: image
	docker load < result
	docker run -p 127.0.0.1:8000:8000/tcp -i -t pyhello /bin/bash
