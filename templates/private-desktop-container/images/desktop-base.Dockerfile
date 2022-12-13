FROM codercom/enterprise-vnc:ubuntu

USER 0

ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND="noninteractive"


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
