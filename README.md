# IMI-SOPHIA Maastricht Study OMOP converter

This repository holds the code to read the Maastricht Study dataset, and convert it into the correct columns in the configured OMOP database.
The main file holding this conversion script is located in [R_script_converted.ipynb](R_script_converted.ipynb).

## Requirements
The following software requirements are needed to run this code:
- R (tested in version 4.3.1)
- on linux: libpq-dev (use `sudo apt update && sudo apt install libpq-dev` to install this package)
- Jupyter Lab with support for R (you can use the `jupyter/datascience-notebook` docker image for convenience, which requires [Docker](https://docs.docker.com/get-started/get-docker/))

**Data requirements**
The data needs to be in a folder outside of this git repository, but next to your current folder in the hierarchy. The code will refer to data files in `../data`.