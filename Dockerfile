# Set name of the default conda environment
ARG conda_env=python36
# Set jupyter default memory usage limit to 6GB (in bytes)
ARG MEM_LIMIT=6442450944
# Set jupyter default cpu usage limit to 6 cores
ARG CPU_LIMIT=6

FROM jupyter/tensorflow-notebook AS build
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html?highlight=python%20version#add-a-python-3-x-environment
# name your environment and choose python 3.6 version
ARG conda_env
ARG py_ver=3.6

# you can add additional libraries you want conda to install by listing them below the first line and ending with "&& \"
RUN conda create --quiet --yes -p $CONDA_DIR/envs/$conda_env python=$py_ver ipython ipykernel \            
    'dask' \
    'dill' \
    'h5py' \
    'ipywidgets' \
    'protobuf' \
    'jupyter-resource-usage' \    
    'statsmodels' \
    'widgetsnbextension' && \
    conda clean --all -f -y

FROM mundialis/esa-snap:ubuntu
ARG conda_env
ARG MEM_LIMIT
ARG CPU_LIMIT
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

USER root

COPY --from=build /usr/local/bin/fix-permissions /usr/local/bin/fix-permissions
RUN chmod a+rx /usr/local/bin/fix-permissions
COPY --from=build /opt/conda/. /opt/conda/

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    PATH=$CONDA_DIR/bin:$PATH

WORKDIR /home/$NB_USER
COPY requirements.txt ./

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc && \
    # Install sudo, required to add the users
    apt-get update && \
    apt-get -y install sudo

COPY --from=build /etc/sudoers /etc/
COPY --from=build /etc/pam.d/su /etc/pam.d/
COPY --from=build /etc/sudoers.d/ /etc/sudoers.d/

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir "/home/$NB_USER/work" && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \
    fix-permissions "/home/$NB_USER"

# Install Proj4 and geo, which are depencies required by cartopy
RUN apt-get update -y && \
    apt-get install -y libproj-dev proj-data proj-bin && \
    apt-get install -y libgeos-dev && \
    # Additionaly install gdal since I'm not sure whether it's necessary
    apt-get install -y libgdal-dev && \
    # Install snappy package
    /opt/conda/envs/python36/bin/python /root/.snap/snap-python/snappy/setup.py install && \
    # Rename package to snappy_esa to avoid conflicts with google's snappy package
    mv /opt/conda/envs/python36/lib/python3.6/site-packages/snappy /opt/conda/envs/python36/lib/python3.6/site-packages/snappy_esa && \
    mv /opt/conda/envs/python36/lib/python3.6/site-packages/snappy_esa/snappy.ini /opt/conda/envs/python36/lib/python3.6/site-packages/snappy_esa/snappy_esa.ini && \
    # Fix env permissions and install python packages from the requirements file
    fix-permissions /opt/conda/envs/python36/lib/python3.6/site-packages/ && \
    /opt/conda/envs/python36/bin/pip install --no-cache-dir -r requirements.txt

# Expose port so that jupyterlab can be accessed outside of the container
EXPOSE 8888

# Copy local files as late as possible to avoid cache busting
COPY --from=build /usr/local/bin/start.sh /usr/local/bin/start-notebook.sh /usr/local/bin/start-singleuser.sh /usr/local/bin/
# Currently need to have both jupyter_notebook_config and jupyter_server_config to support classic and lab
COPY --from=build /etc/jupyter/jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py

RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
# create Python 3.x environment and link it to jupyter
RUN $CONDA_DIR/envs/${conda_env}/bin/python -m ipykernel install --user --name=${conda_env} && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# prepend conda environment to path
ENV PATH=$CONDA_DIR/envs/${conda_env}/bin:$PATH \
    # set this environment to be the default one
    CONDA_DEFAULT_ENV=${conda_env} \
    # Enable jupyterlab
    JUPYTER_ENABLE_LAB=TRUE \
    # Set memory usage limit
    MEM_LIMIT=${MEM_LIMIT}

# Show the CPU usage in Jupyter Lab and Set CPU core limit
RUN echo "c.ResourceUseDisplay.track_cpu_percent = True" >> /etc/jupyter/jupyter_notebook_config.py && \
    echo "c.ResourceUseDisplay.cpu_limit = ${CPU_LIMIT}" >> /etc/jupyter/jupyter_notebook_config.py

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]


