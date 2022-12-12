FROM codercom/enterprise-base:ubuntu

USER coder

# install jupyter lab
RUN pip3 install jupyterlab
