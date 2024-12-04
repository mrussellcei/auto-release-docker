FROM mcr.microsoft.com/dotnet/core/sdk:3.1

LABEL "com.gitbub.actions.name"="Auto Release Milestone"
LABEL "com.github.actions.description"="Drafts a GitHub relase based on a closed Milestone"

LABEL version="0.1.0"
LABEL repository="https://fireresq036/auto-release-Milestone"
LABEL maintainer="Mark Russell"

RUN apt-get update && apt-get indtall -y jq
RUN dotnet tool -g GitReleaseManager.Tool

ENV PATH /root/.dotnet/tools:$PATH

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
