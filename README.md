# ESA Sentinel Toolboxes (SNAP 8) - Jupyter Python Notebook Image

[![Python 3.6](https://img.shields.io/badge/python-3.6-blue.svg)](https://www.python.org/downloads/release/python-360/)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/screamprobation/esa-snap-notebook)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/screamprobation/esa-snap-notebook)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/screamprobation/esa-snap-notebook/snap-8)
![Docker Pulls](https://img.shields.io/docker/pulls/screamprobation/esa-snap-notebook)
![Docker Stars](https://img.shields.io/docker/stars/screamprobation/esa-snap-notebook)

Ubuntu-based [Docker](https://www.docker.com/) image of the [ESA SNAP toolbox (SNAP 8)](http://step.esa.int/main/toolboxes/snap/), installed with: [jupyter](https://jupyter.org/) for efficient prototyping; [apache-beam](https://beam.apache.org/) for parallel pre-procesing of remote sensing imagery; [xarray](http://xarray.pydata.org/en/stable/); [dask](https://dask.org/); [scipy](https://www.scipy.org/); [matplotlib](https://matplotlib.org/); [seaborn](https://seaborn.pydata.org/); [numpy](https://numpy.org/); [pandas](https://pandas.pydata.org/); and ML frameworks, such as [scikit-learn](https://scikit-learn.org/stable/) and [tensorflow 2.X](https://www.tensorflow.org/).

# Download

The image is available on a [Docker Hub repository](https://hub.docker.com/repository/docker/screamprobation/esa-snap-notebook). To download it, you can pull it with the following docker command (make sure you have docker installed):

```console
$ docker pull screamprobation/esa-snap-notebook:snap-8
```

Then, you can run the image with a mounted volume like so:

```console
$ docker run -p 8888:8888 -v /path/to/local/folder:/home/jovyan/work screamprobation/esa-snap-notebook:snap-8
```

If the previous command runs successfully, you should view the jupyterlab link on the terminal screen, which you can access by copying and pasting it on your browser.

# Importing snappy

The python wrapper of SNAP 8 is named snappy. However, there's also a package denominated [snappy](https://pypi.org/project/python-snappy/) from google, which is used by [xarray](https://pypi.org/project/xarray/). Consequently, to avoid any conflicts, the SNAP package was renamed `snappy_esa`, which you can import this package as follows:

```python
import snappy_esa

# Read product from a given path
snappy_esa.ProductIO.readProduct("/path/to/product")

# Apply SNAP operations on product
# ...
```

[This](https://senbox.atlassian.net/wiki/spaces/SNAP/pages/19300362/How+to+use+the+SNAP+API+from+Python) resource might be helpful if you want to learn how to use the SNAP API in Python. [This](https://github.com/techforspace/sentinel) tutorial and [these](https://github.com/senbox-org/snap-engine/tree/master/snap-python/src/main/resources/snappy/examples) example implementations might also be of use.

# Additional Info

Given that `snappy` with python from v.3.7 onwards raises an `Import error - snappy / jpy`, the packages are installed in an anaconda python v.3.6 environment dubbed `python36`, as mentioned [here](https://forum.step.esa.int/t/modulenotfounderror-no-module-named-jpyutil/25785/3?u=screamprobation). This environment is set to be the default conda environment; however, if you get an error importing the package, make sure you are using the `python36` kernel.

# Change default Jupyter memory usage limit and CPU limit

By default, the notebook memory limit of this image was set to **6GB**, with a CPU limit of **6** cores. If you wish to alter these values, you'll have to build an image with this repository's Dockerfile, passing as `--build-arg` the desired memory limit (in bytes) and CPU limit values with the `MEM_LIMIT` and `CPU_LIMIT` arguments, respectively. For example, to build an image with a limit of **4GB** (4294967296 bytes) and **4** cores, with the tag `updated-esa-notebook`, you can use this command:

```console
$ docker build -t updated-esa-notebook --build-arg MEM_LIMIT=4294967296 --build-arg CPU_LIMIT=4 github.com/jpv-costa/ESA-SNAP-notebook.git#main
```

Upon successful completion of the build, you can run the updated image, as you did in [this section](#Download), substituing `screamprobation/esa-snap-notebook:snap-8` for your new image name: `updated-esa-notebook`.
