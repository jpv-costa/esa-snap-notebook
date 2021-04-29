# ESA SNAP 8 Jupyter Notebook Images

Ubuntu based Docker image of the [ESA SNAP toolbox (SNAP 8)](http://step.esa.int/main/toolboxes/snap/), installed as "snappy-esa" to avoid package conflicts, along with jupyter and other scipy, numpy, pandas, and ML frameworks, such as scikit-learn and tensorflow 2.X.

# Docker Hub

Image available in the [following link](https://hub.docker.com/repository/docker/screamprobation/esa-snap-notebook).

# Download

To download the image, you can pull it from the docker hub repository with the following command:

```console
$ docker pull screamprobation/esa-snap-notebook:snap-8
```

Then, you can run the image with a shared volume like so:

```console
$ docker run -p 8888:8888 -v /path/to/local/folder screamprobation/esa-snap-notebook:snap-8
```

# Importing SNAP 8

The python wrapper of SNAP 8 is named snappy. However, there's also a package denominated [snappy](https://pypi.org/project/python-snappy/) from google, which is used by [xarray](https://pypi.org/project/xarray/). Consequently, to avoid any conflicts, the SNAP package was renamed `snappy_esa`, which you can import this package as follows:

```python
import snappy_esa

# Read product from a given path
snappy_esa.ProductIO.readProduct("/path/to/product")

# Apply SNAP operations on product
# ...
```
