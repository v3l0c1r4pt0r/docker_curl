# docker_curl

Unofficial, platform-dependent builds of cURL program and library

## Overview

This image provides lightweight build of cURL program and library. It is statically-linked and detached from any operating system, providing smallest possible system able to utilize cURL with either binary, or library form.

## Usage

To pull image to your system:

```
docker pull v3l0c1r4pt0r/curl:7.77.0-debian-stretch-nossl
```

To create new image with this one as base use this in your Dockerfile:

```
FROM v3l0c1r4pt0r/curl:7.77.0-debian-stretch-nossl
```
