# ESA Sentinel Toolboxes (SNAP 8) - Jupyter Python Notebook Image

[![Python 3.8](https://img.shields.io/badge/python-3.6-blue.svg)](https://www.python.org/downloads/release/python-3810/)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/jpvcosta/esa-snap-notebook)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/jpvcosta/esa-snap-notebook)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/jpvcosta/esa-snap-notebook/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/jpvcosta/esa-snap-notebook)
![Docker Stars](https://img.shields.io/docker/stars/jpvcosta/esa-snap-notebook)
[![CodeFactor](https://www.codefactor.io/repository/github/jpv-costa/esa-snap-notebook/badge)](https://www.codefactor.io/repository/github/jpv-costa/esa-snap-notebook)

esa-snap-notebook is a community maintained Jupyter Docker Stack image of the [ESA SNAP toolbox (SNAP 8)](http://step.esa.int/main/toolboxes/snap/), installed with: [apache-beam](https://beam.apache.org/) for parallel pre-procesing of remote sensing imagery; [xarray](http://xarray.pydata.org/en/stable/); [dask](https://dask.org/); [scipy](https://www.scipy.org/); [matplotlib](https://matplotlib.org/); [seaborn](https://seaborn.pydata.org/); [numpy](https://numpy.org/); [pandas](https://pandas.pydata.org/); and ML frameworks, such as [scikit-learn](https://scikit-learn.org/stable/) and [tensorflow 2.X](https://www.tensorflow.org/).

## Binder

You can play around with the image by clicking on the binder badge below; however, remember to switch to the `python38` kernel, otherwise you won't be able to used the installed packages.

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/jpv-costa/esa-snap-notebook/main)

## Download

The image is available on a [Docker Hub repository](https://hub.docker.com/repository/docker/jpvcosta/esa-snap-notebook). To download it, you can pull it with the following docker command (make sure you have docker installed):

```console
$ docker pull jpvcosta/esa-snap-notebook
```

Then, you can run the image with a mounted volume like so:

```console
$ docker run -p 8888:8888 -v /path/to/local/folder:/home/jovyan/work jpvcosta/esa-snap-notebook
```

If the previous command runs successfully, you should view the jupyterlab link on the terminal screen, which you can access by copying and pasting it on your browser.

## Importing snappy

The python wrapper of SNAP 8 is named snappy. However, there's also a package denominated [snappy](https://pypi.org/project/python-snappy/) from google, which is used by [xarray](https://pypi.org/project/xarray/). Consequently, to avoid any conflicts, the SNAP package was renamed `snappy_esa`, which you can import this package as follows:

```python
import snappy_esa

# Read product from a given path
snappy_esa.ProductIO.readProduct("/path/to/product")

# Apply SNAP operations on product
# ...
```

[This](https://senbox.atlassian.net/wiki/spaces/SNAP/pages/19300362/How+to+use+the+SNAP+API+from+Python) resource might be helpful if you want to learn how to use the SNAP API in Python. [This](https://github.com/techforspace/sentinel) tutorial and [these](https://github.com/senbox-org/snap-engine/tree/master/snap-python/src/main/resources/snappy/examples) example implementations might also be of use.

## Change default Jupyter memory usage limit and CPU limit

By default, the notebook memory limit of this image was set to **6GB**, with a CPU limit of **6** cores. If you wish to alter these values, you'll have to build an image with this repository's Dockerfile, passing as `--build-arg` the desired memory limit (in bytes) and CPU limit values with the `mem_limit` and `cpu_limit` arguments, respectively. For example, to build an image with a limit of **4GB** (4294967296 bytes) and **4** cores, with the tag `updated-esa-notebook`, you can use this command:

```console
$ docker build -t updated-esa-notebook --build-arg mem_limit=4294967296 --build-arg cpu_limit=4 github.com/jpv-costa/ESA-SNAP-notebook.git#main
```

Upon successful completion of the build, you can run the updated image, as you did in [this section](#Download), substituing `jpvcosta/esa-snap-notebook` with your new image name: `updated-esa-notebook`.
