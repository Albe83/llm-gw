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
ARG LITELLM_VERSION=1.74.3
ARG LLM_GW_USER="llm-gw"
# Derived variables
ARG DNF_INSTALL="${DNF} install -y ${DNF_OPTS}"
ARG PIP_CMD=pip${PYTHON_VERSION}

# Note: We avoid 'dnf update' to keep builds reproducible. Instead, use updated base images with pinned digests.
# Optimize DNF installation: use set -euo pipefail, avoid unnecessary caching and ensure cleanup
RUN set -euo pipefail && \
    ${DNF_INSTALL} python${PYTHON_VERSION} python${PYTHON_VERSION}-pip && \
    ${PIP_CMD} install --no-cache-dir --upgrade litellm[proxy]==${LITELLM_VERSION} && \
    ${DNF} remove -y python${PYTHON_VERSION}-pip python3.12-setuptools && \
    ${DNF} clean all && \
    rm -rf /var/cache/dnf/* /var/log/dnf.log /var/log/yum.log /root/.cache/pip /tmp/*

# Create a minimal non-root service user with no home directory
RUN useradd --system --no-create-home --shell /sbin/nologin ${LLM_GW_USER}
# Copy the LiteLLM Proxy configuration file
ARG LITELLM_CONFIG_FILE=litellm_config.yaml
COPY --chown=${LLM_GW_USER}:${LLM_GW_USER} --chmod=0400 ${LITELLM_CONFIG_FILE} /${LITELLM_CONFIG_FILE}

USER ${LLM_GW_USER}
WORKDIR /

# Add OCI-compliant labels for better image metadata
LABEL org.opencontainers.image.title="LLM Gateway" \
      org.opencontainers.image.description="A lightweight container running LiteLLM Proxy with Oracle Linux." \
      org.opencontainers.image.authors="Albe83" \
      org.opencontainers.image.source="https://github.com/Albe83/llm-gw" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${LITELLM_VERSION}"