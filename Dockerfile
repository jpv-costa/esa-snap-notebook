ARG BASE_CONTAINER=jupyter/tensorflow-notebook
FROM $BASE_CONTAINER:bbf0ada0a935

# Set jupyter default memory usage limit to 6GB (in bytes)
ARG mem_limit=6442450944
# Set jupyter default cpu usage limit to 6 cores
ARG cpu_limit=6
# Set name of the default conda environment
ARG conda_env=python38
# Set the python version of the environment
ARG py_ver=3.8

WORKDIR $HOME

USER root

RUN echo "c.ResourceUseDisplay.track_cpu_percent = True" >> /etc/jupyter/jupyter_notebook_config.py && \
    echo "c.ResourceUseDisplay.cpu_limit = ${cpu_limit}" >> /etc/jupyter/jupyter_notebook_config.py

COPY --chown=${NB_UID}:${NB_GID} requirements.txt ./

RUN apt-get update -y && \
    # Install Proj4 and geo, which are depencies required by cartopy
    apt-get install -y --no-install-recommends \ 
    libproj-dev \
    proj-data \
    proj-bin \
    libgeos-dev \
    libgdal-dev \
    software-properties-common=* && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

ENV SITE_PACKAGES=$CONDA_DIR/envs/$conda_env/lib/python3.8/site-packages \
    SNAP_HOME=$CONDA_DIR/envs/$conda_env/snap

RUN conda env create -p $CONDA_DIR/envs/$conda_env -f environment.yml && \
    # Install snappy package
    cd /opt/conda/envs/$conda_env/bin/ && \
    ./python $SNAP_HOME/.snap/snap-python/snappy/setup.py install && \
    # Rename package to snappy_esa to avoid conflicts with google's snappy package
    mv $SITE_PACKAGES/snappy $SITE_PACKAGES/snappy_esa && \
    mv $SITE_PACKAGES/snappy_esa/snappy.ini $SITE_PACKAGES/snappy_esa/snappy_esa.ini && \
    # create Python 3.x environment and link it to jupyter
    ./python -m ipykernel install --user --name=${conda_env} && \
    $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.core && \
    $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.olci && \
    # Fix permissions
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    conda clean --all -f -y

# Enable jupyterlab
ENV JUPYTER_ENABLE_LAB=TRUE \
    # Set default environment
    CONDA_DEFAULT_ENV=${conda_env} \
    # Set memory usage limit
    MEM_LIMIT=${mem_limit} \    
    GPT_BIN=$SNAP_HOME/bin/gpt
