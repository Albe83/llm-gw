# Base image with pinned SHA256 digest for reproducibility
# To update the digest, run:
#   docker pull oraclelinux:9-slim
#   docker inspect oraclelinux:9-slim --format='{{index .RepoDigests 0}}'
ARG BASE_IMAGE_NAME=oraclelinux
ARG BASE_IMAGE_TAG=9-slim
ARG BASE_IMAGE_DIGEST=sha256:5663c32905e22f7b8c88247bc55125d12fbe9b14c0bab5c766181e7266b46cf1
ARG BASE_IMAGE=${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}@${BASE_IMAGE_DIGEST}

FROM ${BASE_IMAGE} AS base

# Build arguments
ARG DNF=microdnf
ARG DNF_OPTS="--nodocs"
ARG PYTHON_VERSION=3.12
ARG LITELL_VERSION=1.74.3

# Derived variables
ARG DNF_INSTALL="${DNF} install -y ${DNF_OPTS}"
ARG PIP_CMD=pip${PYTHON_VERSION}

# Note: We avoid 'dnf update' to keep builds reproducible. Instead, use updated base images with pinned digests.
# Optimize DNF installation: use set -euo pipefail, avoid unnecessary caching and ensure cleanup
RUN set -euo pipefail && \
    ${DNF_INSTALL} python${PYTHON_VERSION} python${PYTHON_VERSION}-pip && \
    ${PIP_CMD} install --no-cache-dir --upgrade litellm[proxy]==${LITELL_VERSION} && \
    ${DNF} remove -y python${PYTHON_VERSION}-pip python3.12-setuptools && \
    ${DNF} clean all && \
    rm -rf /var/cache/dnf/* /var/log/dnf.log /var/log/yum.log /root/.cache/pip /tmp/*
