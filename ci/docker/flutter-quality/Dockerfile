# App-Flutter: quality-only image for the Woodpecker linux/amd64 agent.
# Android SDK/NDK, Xcode, signing tools and release credentials are out of scope.
FROM ubuntu:24.04

ARG FLUTTER_VERSION=3.47.6
ARG FLUTTER_REVISION=5fc346839b5d0eef006ed8404392afb4dfae428d

ENV DEBIAN_FRONTEND=noninteractive \
    CI=true \
    PUB_CACHE=/opt/pub-cache \
    PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
        libgl1 \
        fontconfig \
    && rm -rf /var/lib/apt/lists/*

# Fetch a fixed release and verify its exact git commit before installing tools.
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" \
        https://github.com/flutter/flutter.git /opt/flutter \
    && actual="$(git -C /opt/flutter rev-parse HEAD)" \
    && echo "Flutter revision: ${actual}" \
    && test "${actual}" = "${FLUTTER_REVISION}"

# Warm Dart/Flutter tool snapshots and Linux artifacts in the image.
# No Android SDK or native mobile build tools are installed here.
RUN flutter config --no-analytics \
    && dart --disable-analytics \
    && flutter precache --linux \
    && flutter --version \
    && dart --version

WORKDIR /workspace
