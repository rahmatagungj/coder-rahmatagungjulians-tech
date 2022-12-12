FROM codercom/enterprise-vnc:ubuntu

ENV SHELL=/bin/bash

USER root

# Install Nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt install -y nodejs

USER coder

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# install jupyter lab
RUN pip3 install jupyterlab
