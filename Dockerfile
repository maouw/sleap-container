ARG MICROMAMBA_TAG=jammy-cuda-12.1.1
ARG SLEAP_PYTHON_VERSION=3.7.12
ARG SLEAP_VERSION=1.3.3

# Use the specified base image
FROM mambaorg/micromamba:${MICROMAMBA_TAG:-jammy-cuda-12.1.1}

# Automatically activate base environment for mamba/conda
ENV MAMBA_DOCKERFILE_ACTIVATE=1

# Install sleap
RUN micromamba install -y -n base python="${SLEAP_PYTHON_VERSION:-3.7.12}" -c conda-forge -c nvidia -c sleap -c anaconda sleap=1.3.3
