# Python Install

This is for educational and research purposes only. 

The Dockerfile contains the install for Anaconda 3 (Python 3), sets up the bash environment for conda commands, and installs a selection of Python packages used in BCB projects.

The Dockerfile uses a Fedora 38 base. (Fedora is stable and upstream of CentOS and RHEL.) Because our project requires Tomcat, Java, Python, and R at different times and combination, we install these applications into a base image rather than using pre-builts.

Search the Dockerfile for "Requirements for MBatch Python install/setup".

The first run block downloads Anaconda3 from anaconda.com and installs it locally to /home/bcbuser/conda. The activate, init, and an initial update for conda are also done.

Previous OS-level requirements are installed under the first step for R. Notably, express-generator, which is used to compile Python executables, has an unpatched critical vulnerability as of this writing - do not run this image exposed to outside world.

```
RUN mkdir -p /home/bcbuser && \
    cd /home/bcbuser && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh && \
    mkdir /home/bcbuser/conda && \
    bash /home/bcbuser/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh -b -p /home/bcbuser/conda -f && \
    source /home/bcbuser/conda/bin/activate && \
    conda init && \
    conda update -y conda
```

Then we set the environmental variable LD_LIBRARY_PATH. We do this so that when a Python package uses a shared library (so file) that is different from the version installed, it looks in the Anaconda libraries directory for it, before looking at the OS level. The path uses the name and install directory for the gendev Conda environment created in the following step.

```
# LD_LIBRARY_PATH needed for Python to find libraries due to conda env issues
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/bcbuser/conda/envs/gendev/lib
```

After activating and running init for Conda (necessary since the unattended install required for Docker does not automatically activate Conda), we create and activate the Conda environment gendev.

Note the full path to where to create and find gendev. This is done so the environment is locatable and available to all users.

Then we install packages we use.

```
RUN source /home/bcbuser/conda/bin/activate && \
    conda init && \
    conda create -y -p /home/bcbuser/conda/envs/gendev && \
    conda activate /home/bcbuser/conda/envs/gendev && \
    conda install -y -c conda-forge python==3.11.* && \
    conda install -y -c conda-forge pyinstaller && \
    conda install -y -c conda-forge flask && \
    conda install -y -c conda-forge waitress && \
    conda install -y -c conda-forge pylint && \
    conda install -y -c conda-forge setuptools && \
    conda install -y -c conda-forge pandas && \
    conda install -y -c conda-forge numpy && \
    conda install -y -c conda-forge matplotlib && \
    conda install -y -c conda-forge scanpy && \
    conda install -y -c conda-forge pillow && \
    conda install -y -c conda-forge jsonpickle && \
    conda install -y -c conda-forge requests && \
    conda install -y -c conda-forge xmltodict && \
    conda install -y -c conda-forge cryptography && \
    conda install -y -c conda-forge urllib3 && \
    conda install -y -c conda-forge scipy && \
    pip install pex
```

We copy a previously created bashrc for conda into the system bashrc at /etc/bashrc. This ensures all users on the system get Conda available in their bash environment.

Not that we first copy the installations directory from outside the image into the /bcbsetup/ directory inside the image. Also note the reminder that COPY in a Dockerfile is always done as root. If non-root users need access, you will need to change ownership or permissions after the COPY. The use of the external installations directory is a "standard" used in all our Dockerfile builds.

```
# copy installs
# COPY is always done as root!!!!
COPY installations /bcbsetup/.

# add universal access to conda
RUN cat /etc/bashrc /bcbsetup/conda.txt >> /bcbsetup/bashrc && \
    cp /bcbsetup/bashrc /etc/bashrc
```

The previously created bashrc entry looks like this:

```
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/bcbuser/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/bcbuser/conda/etc/profile.d/conda.sh" ]; then
        . "/home/bcbuser/conda/etc/profile.d/conda.sh"
    else
        export PATH="/home/bcbuser/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```

Finally, set the RETICULATE_PYTHON variable in the Renviron file, so we always use the correct version of Python. (This is not always needed, but sometimes we have limited control over the defaults R selected, and this addresses those cases.)

```
RUN echo 'RETICULATE_PYTHON="/home/bcbuser/conda/envs/gendev/bin/python3"' >> /usr/lib64/R/etc/Renviron
```


