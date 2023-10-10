Bootstrap: docker
From: mambaorg/micromamba:jammy-cuda-12.1.1

%environment
	export MAMBA_DOCKERFILE_ACTIVATE=1

%post
	micromamba install -y -n base python=3.7.12 -c conda-forge -c nvidia -c sleap -c anaconda sleap=1.3.3

