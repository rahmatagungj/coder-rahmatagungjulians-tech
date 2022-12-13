FROM codercom/enterprise-vnc:ubuntu

USER root

ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt update -y && \
    apt install -y apt-transport-https software-properties-common wget


# Git
RUN add-apt-repository ppa:git-core/ppa -y

RUN apt update -y

# Basic tools
RUN apt install -y sudo doas

# Create coder user
RUN useradd coder --create-home --shell=/bin/bash --uid=1000 --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd         && \
    echo "permit nopass coder as root" >> /etc/doas.conf


# nvm + node + pnpm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ]    && \
    . "$NVM_DIR/nvm.sh"         && \
    nvm install node            && \
    npm i -g pnpm npm

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN mkdir projects

# install jupyter lab
RUN pip3 install jupyterlab

# Extensions gallery for code-server (Microsoft instead of OpenVSIX -> for when you use coder/code-server)
ENV EXTENSIONS_GALLERY='{"serviceUrl":"https://marketplace.visualstudio.com/_apis/public/gallery","cacheUrl":"https://vscode.blob.core.windows.net/gallery/index","itemUrl":"https://marketplace.visualstudio.com/items","controlUrl":"","recommendationsUrl":""}'
ENV DEBIAN_FRONTEND="dialog"
ENV LANG="en_US.UTF-8"