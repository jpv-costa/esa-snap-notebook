ARG base_container=jpvcosta/esa-snap-notebook
FROM $base_container:b972770073fa@sha256:ba9a415e5ea3dc1f460c8c8da3c6d1fce998f2d5ba1930158b4a0062cff20d61

ENV TAG="b972770073fa"

WORKDIR $HOME

COPY binder/snap-demo.ipynb .

# Fix permissions on snap-demo.ipynb as root
USER root

RUN fix-permissions snap-demo.ipynb

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME