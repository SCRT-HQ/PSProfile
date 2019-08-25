FROM mcr.microsoft.com/powershell:ubuntu-16.04 as base
RUN apt-get update && apt-get install -y git

FROM base as src
LABEL maintainer="nferrell"
LABEL description="PSProfile container for Ubuntu 16.04"
LABEL vendor="scrthq"
COPY [".", "/tmp/PSProfile/"]
WORKDIR /tmp/PSProfile
