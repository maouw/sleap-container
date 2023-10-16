Bootstrap: docker
From: mambaorg/micromamba:{{ MICROMAMBA_TAG }}

%arguments
	MICROMAMBA_TAG=jammy-cuda-12.1.1
	SLEAP_PYTHON_VERSION=3.7.12
	SLEAP_VERSION=1.3.3

%environment
	export MAMBA_DOCKERFILE_ACTIVATE=1

%post
	micromamba install -y -n base python={{ SLEAP_PYTHON_VERSION }} -c conda-forge -c nvidia -c sleap -c anaconda sleap={{ SLEAP_VERSION }}

