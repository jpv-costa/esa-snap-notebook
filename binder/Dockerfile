ARG base_container=jpvcosta/esa-snap-notebook:pyspark-b972770073fa
FROM $base_container

ENV TAG="pyspark-b972770073fa"

COPY binder/snap-demo.ipynb .

# Fix permissions on snap-demo.ipynb as root
USER root

RUN fix-permissions snap-demo.ipynb

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME