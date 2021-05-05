ARG base_container=jpvcosta/esa-snap-notebook:2c66a2174ccc
FROM $base_container

ENV TAG="2c66a2174ccc"

COPY binder/snap-demo.ipynb .

# Fix permissions on snap-demo.ipynb as root
USER root

RUN fix-permissions snap-demo.ipynb

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME