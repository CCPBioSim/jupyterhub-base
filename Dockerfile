# Start with JupyterHub image.
FROM quay.io/jupyter/base-notebook:3b755d1c0c87

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"
LABEL org.opencontainers.image.source=https://github.com/ccpbiosim/jupyterhub-base
LABEL org.opencontainers.image.description="A base container image derived from jupyterhub base containers with some extra utilities installed."
LABEL org.opencontainers.image.licenses=MIT


# Root to install "rooty" things.
USER root

# Update the OS and install software dependencies
# needing root.
RUN apt-get update && apt-get -yq dist-upgrade \
 && apt-get install -yq --no-install-recommends \
    bc \
    bison \
    build-essential \
    bzip2 \
    cmake \
    curl \
    flex \
    gfortran \
    git \
    libz-dev \
    libbz2-dev \
    make \
    nano \
    openssh-client \
    patch \
    rsync \
    sed \
    tcsh \
    unzip \
    vim \
    wget \
    xorg-dev \
    xz-utils \
    zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Modified index for matomo metrics.
#COPY --chown=1000:100 index.html /opt/conda/share/jupyter/lab/static/index.html
COPY --chown=1000:100 matomo-js.txt /tmp

RUN sed -e '/<\/body><\/html>/ {' -e 'r /tmp/matomo-js.txt' -e 'd' -e '}' -i /opt/conda/share/jupyter/lab/static/index.html

# Switch to jovyan user.
USER $NB_USER
WORKDIR $HOME

# Add authenticator
RUN pip install jupyterhub-tmpauthenticator

# Remove work directory as it not required.
RUN rm -r $HOME/work

# Change the loooong default terminal string
RUN echo 'export PS1="\u:\W\$ "' >> /home/jovyan/.bashrc

# Always finish with non-root user as a precaution.
USER $NB_USER
