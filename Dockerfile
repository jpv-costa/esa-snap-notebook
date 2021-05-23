
# ARG BASE_CONTAINER=jupyter/base-notebook
# FROM $BASE_CONTAINER:notebook-6.3.0

# # Set jupyter default memory usage limit to 6GB (in bytes)
# ARG mem_limit=6442450944
# # Set jupyter default cpu usage limit to 6 cores
# ARG cpu_limit=6
# # Set name of the default conda environment
# ARG conda_env=python38
# # Set the python version of the environment
# ARG py_ver=3.8

# WORKDIR $HOME

# USER root

# RUN echo "c.ResourceUseDisplay.track_cpu_percent = True" >> /etc/jupyter/jupyter_notebook_config.py && \
#     echo "c.ResourceUseDisplay.cpu_limit = ${cpu_limit}" >> /etc/jupyter/jupyter_notebook_config.py

# COPY --chown=${NB_UID}:${NB_GID} requirements.txt ./
# COPY --chown=${NB_UID}:${NB_GID} environment.yml ./

# #Update python version in the environment file
# RUN sed -i "s/\$py_ver/$py_ver/g" environment.yml && \
#     cat environment.yml

# RUN apt-get update -y && \
#     # Install Proj4 and geo, which are depencies required by cartopy
#     apt-get install -y --no-install-recommends \ 
#     libproj-dev \
#     proj-data \
#     proj-bin \
#     libgeos-dev \
#     libgdal-dev \
#     software-properties-common=* && \
#     add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# # Switch back to jovyan to avoid accidental container runs as root
# USER $NB_UID

# ENV SITE_PACKAGES=$CONDA_DIR/envs/$conda_env/lib/python3.8/site-packages \
#     SNAP_HOME=$CONDA_DIR/envs/$conda_env/snap



# RUN conda env create -p $CONDA_DIR/envs/$conda_env -f environment.yml && \
#     # Install snappy package
#     cd /opt/conda/envs/$conda_env/bin/ && \
#     ./python $SNAP_HOME/.snap/snap-python/snappy/setup.py install && \
#     # Rename package to snappy_esa to avoid conflicts with google's snappy package
#     mv $SITE_PACKAGES/snappy $SITE_PACKAGES/snappy_esa && \
#     mv $SITE_PACKAGES/snappy_esa/snappy.ini $SITE_PACKAGES/snappy_esa/snappy_esa.ini && \
#     # Install python packages from the requirements file    
#     ./pip install --no-cache-dir -r $HOME/requirements.txt && \ 
#     # create Python 3.x environment and link it to jupyter
#     ./python -m ipykernel install --user --name=${conda_env} && \
#     $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.core && \
#     $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.olci && \
#     # Fix permissions
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER && \
#     conda clean --all -f -y

# # Enable jupyterlab
# ENV JUPYTER_ENABLE_LAB=TRUE \
#     # Set default environment
#     CONDA_DEFAULT_ENV=${conda_env} \
#     # Set memory usage limit
#     MEM_LIMIT=${mem_limit} \    
#     GPT_BIN=$SNAP_HOME/bin/gpt

# ARG BASE_CONTAINER=jupyter/tensorflow-notebook:bbf0ada0a935
# FROM $BASE_CONTAINER

# # Set jupyter default memory usage limit to 6GB (in bytes)
# ARG mem_limit=6442450944
# # Set jupyter default cpu usage limit to 6 cores
# ARG cpu_limit=6
# # Set name of the default conda environment
# ARG conda_env=python38
# # Set the python version of the environment
# ARG py_ver=3.8

# USER root

# RUN echo "c.ResourceUseDisplay.track_cpu_percent = True" >> /etc/jupyter/jupyter_notebook_config.py && \
#     echo "c.ResourceUseDisplay.cpu_limit = ${cpu_limit}" >> /etc/jupyter/jupyter_notebook_config.py

# COPY --chown=${NB_UID}:${NB_GID} requirements.txt ./

# RUN apt-get update -y && \
#     # Install Proj4 and geo, which are depencies required by cartopy
#     apt-get install -y libproj-dev proj-data proj-bin && \
#     apt-get install -y libgeos-dev && \
#     apt-get install -y libgdal-dev && \
#     apt-get install -y --no-install-recommends \
#     software-properties-common=* && \
#     add-apt-repository ppa:deadsnakes/ppa

# # Switch back to jovyan to avoid accidental container runs as root
# USER $NB_UID

# ENV SITE_PACKAGES=$CONDA_DIR/envs/$conda_env/lib/python3.8/site-packages \
#     SNAP_HOME=$CONDA_DIR/envs/$conda_env/snap

# RUN conda config --append channels terradue && \
#     conda config --append channels defaults && \
#     conda list -e > conda_requirements.txt && \
#     echo $' \n\
#     ipython=7.23.0 \n\
#     ipykernel=5.5.3 \n\
#     java-1.7.0-openjdk-cos6-x86_64=1.7.0.131 \n\
#     jpy=0.9.0 \n\
#     snap=8.0.0=py38_2 \n\
#     jupyter-resource-usage=0.6.0' >> conda_requirements.txt && \
#     conda create --yes -p $CONDA_DIR/envs/$conda_env python=$py_ver --file conda_requirements.txt && \
#     # Install snappy package
#     cd /opt/conda/envs/$conda_env/bin/ && \
#     ./python $SNAP_HOME/.snap/snap-python/snappy/setup.py install && \
#     # Rename package to snappy_esa to avoid conflicts with google's snappy package
#     mv $SITE_PACKAGES/snappy $SITE_PACKAGES/snappy_esa && \
#     mv $SITE_PACKAGES/snappy_esa/snappy.ini $SITE_PACKAGES/snappy_esa/snappy_esa.ini && \
#     # Install python packages from the requirements file    
#     ./pip install --no-cache-dir -r $HOME/requirements.txt && \   
#     # create Python 3.x environment and link it to jupyter
#     ./python -m ipykernel install --user --name=${conda_env} && \
#     $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.core && \
#     $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.olci && \
#     # $SNAP_HOME/bin/snap --nosplash --nogui --modules --list --refresh && \
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER && \
#     conda clean --all -f -y

# # Enable jupyterlab
# ENV JUPYTER_ENABLE_LAB=TRUE \
#     # Set default environment
#     CONDA_DEFAULT_ENV=${conda_env} \
#     # Set memory usage limit
#     MEM_LIMIT=${mem_limit} \    
#     GPT_BIN=$SNAP_HOME/bin/gpt
ARG BASE_CONTAINER=jupyter/base-notebook
FROM $BASE_CONTAINER:notebook-6.3.0 as utils

# ARG BASE_CONTAINER=jupyter/scipy-notebook
# FROM $BASE_CONTAINER:cf6258237ff9

# # Set jupyter default memory usage limit to 6GB (in bytes)
# ARG mem_limit=6442450944
# # Set jupyter default cpu usage limit to 6 cores
# ARG cpu_limit=6
# # Set the python version of the environment
# ARG py_ver=3.7

# WORKDIR $HOME
FROM jcrist/alpine-conda:4.6.8

USER root

# RUN echo "c.ResourceUseDisplay.track_cpu_percent = True" >> /etc/jupyter/jupyter_notebook_config.py && \
#     echo "c.ResourceUseDisplay.cpu_limit = ${cpu_limit}" >> /etc/jupyter/jupyter_notebook_config.py

COPY --chown=${NB_UID}:${NB_GID} requirements.txt ./
COPY --chown=${NB_UID}:${NB_GID} environment.yml ./
# COPY --from=utils --chown=${NB_UID}:${NB_GID} /usr/local/bin/fix-permissions /usr/local/bin/
# RUN chmod a+rx /usr/local/bin/fix-permissions

#Update python version in the environment file
# RUN sed -i "s/\$py_ver/$py_ver/g" environment.yml \
#     && cat environment.yml

# RUN apt-get update -y && \
#     # Install Proj4 and geo, which are depencies required by cartopy
#     apt-get install -y --no-install-recommends \ 
#     libproj-dev \
#     proj-data \
#     proj-bin \
#     libgeos-dev \
#     libgdal-dev \
#     software-properties-common=* && \
#     add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# Switch back to jovyan to avoid accidental container runs as root
# USER ${USER}
ENV CONDA_DIR=/opt/conda \
    PATH=/opt/conda/bin:${PATH}
# ENV SITE_PACKAGES=$CONDA_DIR/lib/python3.8/site-packages \
#     SNAP_HOME=$CONDA_DIR/snap

# snap requires bash to be installed
RUN apk add --no-cache bash \
    && conda env update -f environment.yml 
# Install snappy package
#cd /opt/conda/bin/ && \
#./python $SNAP_HOME/.snap/snap-python/snappy/setup.py install && \
# Rename package to snappy_esa to avoid conflicts with google's snappy package
#mv $SITE_PACKAGES/snappy $SITE_PACKAGES/snappy_esa && \
#mv $SITE_PACKAGES/snappy_esa/snappy.ini $SITE_PACKAGES/snappy_esa/snappy_esa.ini && \
# # Install python packages from the requirements file    
# ./pip install --no-cache-dir -r $HOME/requirements.txt && \ 
# # create Python 3.x environment and link it to jupyter
# ./python -m ipykernel install --user --name=${conda_env} && \
# $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.core && \
# $SNAP_HOME/bin/snap --nosplash --nogui --modules --install org.esa.snap.idepix.olci && \
# # Fix permissions
# && fix-permissions $CONDA_DIR \
# && fix-permissions /home/$NB_USER \
# && /opt/conda/bin/conda clean --all -f -y

# Enable jupyterlab
ENV JUPYTER_ENABLE_LAB=TRUE \
    # Set default environment
    # CONDA_DEFAULT_ENV=${conda_env} \
    # Set memory usage limit
    MEM_LIMIT=${mem_limit} \
    GPT_BIN=$SNAP_HOME/bin/gpt

ENTRYPOINT ["bash"]