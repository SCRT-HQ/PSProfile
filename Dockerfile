FROM mcr.microsoft.com/powershell:ubuntu-18.04 as base
RUN apt-get update && apt-get install -y git

FROM base as src
LABEL maintainer="nferrell"
LABEL description="Ubuntu 16.04 for PowerShell module testing in CI"
LABEL vendor="scrthq"
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $VerbosePreference = 'Continue'; $ProgressPreference = 'SilentlyContinue';"]
COPY [".", "/Source/"]
WORKDIR /Source
ENTRYPOINT [ "pwsh", "-command", ". ./build.ps1 -Task Test" ]
