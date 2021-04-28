ARG conda_env=python36
FROM jupyter/tensorflow-notebook AS build
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/recipes.html?highlight=python%20version#add-a-python-3-x-environment
# name your environment and choose python 3.6 version
ARG conda_env
ARG py_ver=3.6

# you can add additional libraries you want conda to install by listing them below the first line and ending with "&& \"
RUN conda create --quiet --yes -p $CONDA_DIR/envs/$conda_env python=$py_ver ipython ipykernel \    
    'beautifulsoup4' \
    'bokeh' \
    'bottleneck' \
    'cloudpickle' \
    'dask' \
    'dill' \
    'h5py' \
    'ipywidgets' \
    'ipympl'\
    'matplotlib-base' \
    'numba' \
    'numexpr' \
    'pandas' \
    'patsy' \
    'protobuf' \
    'pytables' \
    'scikit-image' \
    'scikit-learn' \
    'scipy' \
    'seaborn' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy' \
    'vincent' \
    'widgetsnbextension'\
    'xlrd' && \
    conda clean --all -f -y

# alternatively, you can comment out the lines above and uncomment those below
# if you'd prefer to use a YAML file present in the docker build context

# COPY --chown=${NB_UID}:${NB_GID} environment.yml /home/$NB_USER/tmp/
# RUN cd /home/$NB_USER/tmp/ && \
#     conda env create -p $CONDA_DIR/envs/$conda_env -f environment.yml && \
#     conda clean --all -f -y


# create Python 3.x environment and link it to jupyter
# RUN $CONDA_DIR/envs/${conda_env}/bin/python -m ipykernel install --user --name=${conda_env} && \
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER

# any additional pip installs can be added by uncommenting the following line
# RUN $CONDA_DIR/envs/${conda_env}/bin/pip install

# # prepend conda environment to path
# ENV PATH $CONDA_DIR/envs/${conda_env}/bin:$PATH

# # if you want this environment to be the default one, uncomment the following line:
# ENV CONDA_DEFAULT_ENV ${conda_env}

FROM mundialis/esa-snap:ubuntu

ARG conda_env

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
    NB_GID=$NB_GID

WORKDIR /home/$NB_USER
COPY requirements.txt ./

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

RUN apt-get update && \
      apt-get -y install sudo

COPY --from=build /etc/sudoers /etc/
COPY --from=build /etc/pam.d/su /etc/pam.d/
COPY --from=build /etc/sudoers.d/ /etc/sudoers.d/
# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
# RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
#     sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#     sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

ENV PATH=$CONDA_DIR/bin:$PATH

# Setup work directory for backward-compatibility
# RUN mkdir "/home/$NB_USER"
# RUN mkdir "/home/$NB_USER/work" 
# RUN chown $NB_USER:$NB_GID $CONDA_DIR 
# RUN chmod g+w /etc/passwd 
# RUN fix-permissions "/home/$NB_USER"
RUN mkdir "/home/$NB_USER/work" && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \
    fix-permissions "/home/$NB_USER"
# RUN mkdir "/home/$NB_USER" && \
#     mkdir "/home/$NB_USER/work" && \
#     chown $NB_USER:$NB_GID $CONDA_DIR && \
#     chmod g+w /etc/passwd && \
#     fix-permissions "/home/$NB_USER"

# Install snappy package
RUN /opt/conda/envs/python36/bin/python /root/.snap/snap-python/snappy/setup.py install && \
   mv /opt/conda/envs/python36/lib/python3.6/site-packages/snappy /opt/conda/envs/python36/lib/python3.6/site-packages/snappy_esa && \
   mv /opt/conda/envs/python36/lib/python3.6/site-packages/snappy_esa/snappy.ini /opt/conda/envs/python36/lib/python3.6/site-packages/snappy_esa/snappy_esa.ini

# Install Proj4 and geo, which are depencies required by cartopy
# Additionaly install gdal since I'm not sure whether it's necessary
RUN apt-get update -y && \
    apt-get install -y libproj-dev proj-data proj-bin && \
    apt-get install -y libgeos-dev && \
    apt-get install -y libgdal-dev

#RUN conda install -c conda-forge --yes proj-data
# Install python packages with pip
RUN fix-permissions /opt/conda/envs/python36/lib/python3.6/site-packages/ && \
    /opt/conda/envs/python36/bin/pip install --no-cache-dir -r requirements.txt

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
ENV PATH $CONDA_DIR/envs/${conda_env}/bin:$PATH

# if you want this environment to be the default one, uncomment the following line:
ENV CONDA_DEFAULT_ENV ${conda_env}

ENV JUPYTER_ENABLE_LAB TRUE

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]


