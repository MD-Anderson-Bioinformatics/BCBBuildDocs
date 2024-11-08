FROM fedora:40

## use the docker compose file to build

# NOTE: to create your own user, add to bcb_base_group to access-preinstalled apps/files

# reminder, use {} around environmental variables, otherwise docker uses it as a literal

LABEL edu.mda.bcb.name="bcb_build_docs" \
      edu.mda.bcb.sub="bde" \
      edu.mda.bcb.coj.version="2024-07-03-0930" \
      edu.mda.bcb.coj.Rversion="4.x" \
      edu.mda.bcb.coj.Javaversion="17" \
      edu.mda.bcb.coj.Linuxversion="Fedora 40"

####
#### generic setup for OS
####

# set timezone to prevent R time warnings
RUN ln -snf /usr/share/zoneinfo/US/Central /etc/localtime && echo "US/Central" > /etc/timezone
ENV TZ=US/Central

####
#### Make group to allow later users to access files,
#### without duplicating files/dirs in layer with chmod/chown
####

RUN groupadd -g 131313 bcb_base_group

####
#### Install/Setup Java 17 with variables
####

RUN dnf upgrade -y && \
    dnf -y install java-17-openjdk java-17-openjdk-devel java-17-openjdk-headless && \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk/bin/java 1 && \
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-openjdk/bin/javac 1 && \
    update-alternatives --set java /usr/lib/jvm/java-17-openjdk/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-17-openjdk/bin/javac && \
    dnf upgrade -y && \
    dnf clean all

# adding these variables fixes issue where registering Java with R (keeps getting "lost")
ENV JAR=/usr/lib/jvm/java-17-openjdk/bin/jar 
ENV JAVAH=/usr/lib/jvm/java-17-openjdk/bin/javac 
ENV JAVA_LIBS="-L/usr/lib/jvm/java-17-openjdk/lib/server -ljvm" 
ENV JAVA_CPPFLAGS="-I/usr/lib/jvm/java-17-openjdk/include -I/usr/lib/jvm/java-17-openjdk/include/linux" 
ENV JAVA_LD_LIBRARY_PATH=/usr/lib/jvm/java-17-openjdk/lib/server
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk/
ENV PATH=/usr/lib/jvm/java-17-openjdk/bin:$PATH
ENV JAVA=/usr/lib/jvm/java-17-openjdk/bin/java
ENV JAVAC=/usr/lib/jvm/java-17-openjdk/bin/javac
ENV JAVAH=/usr/lib/jvm/java-17-openjdk/bin/javac
ENV JAR=/usr/lib/jvm/java-17-openjdk/bin/jar
ENV LD_LIBRARY_PATH=/usr/lib/jvm/java-17-openjdk/lib/server

####
#### Install/Setup R 4.x+ plus OS packages for MBatch
####

# installs for R-related elements (like cairo)
# and build elements like Git and Maven
RUN dnf upgrade -y && \
    dnf -y install dnf-plugins-core && \
    dnf -y install libstdc++ ffmpeg-free ffmpeg-free-devel unzip diffutils openssl-devel libxml2-devel cairo-devel libXt-devel udunits2-devel proj-devel geos-devel gdal-devel sqlite sqlite-devel perl-Tk git git-gui ant maven nodejs file wget harfbuzz fribidi harfbuzz-devel fribidi-devel libcurl-devel freetype-devel libpng-devel libtiff-devel libjpeg-turbo-devel tesseract tesseract-devel leptonica-devel cargo poppler-cpp-devel ImageMagick-c++-devel libwebp-devel librsvg2-devel libgit2-devel gsl gsl-devel && \
    dnf upgrade -y && \
    dnf clean all && \
    npm install -g express-generator
    #####
    ##### IMPORTANT - DO NOT RUN THIS EXPOSED TO OUTSIDE WORLD
    #####
    # express-generator has unpatched critical vulnerability - do not run this image exposed to outside world

# Install subset of TexLive
RUN dnf upgrade -y && \
    dnf install -y texlive-2023 texlive-framed && \
    dnf upgrade -y && \
    dnf clean all

# install pandoc after texlive, since it depends on texlive
RUN dnf upgrade -y && \
    dnf -y install pandoc && \
    dnf upgrade -y && \
    dnf clean all

# install R 4.x+
RUN dnf upgrade -y && \
    dnf install -y R-java-devel && \
    dnf upgrade -y && \
    dnf clean all

RUN echo 'LC_CTYPE="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_TIME="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_MESSAGES="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_MONETARY="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_PAPER="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_MEASUREMENT="C"' >> /usr/lib64/R/etc/Renviron

# register Java with R
RUN R CMD javareconf

####
#### Python installs
####

# bcbuser is not created yet, so make dir, and chown/cmod


# Please note, we use the Conda-Forge install of conda via MiniForge. This setup uses only the conda-forge channel
# to avoid using the licensed Anaconda Inc channels.
RUN mkdir /home/bcbuser && \
    cd /home/bcbuser && \
    curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && \
    mkdir /home/bcbuser/conda && \
    bash /home/bcbuser/Miniforge3-Linux-x86_64.sh -b -p /home/bcbuser/conda -f && \
    . /home/bcbuser/conda/bin/activate && \
    conda init && \
    conda update -y -n base -c conda-forge conda && \
    conda init bash && \
    chown -R :bcb_base_group /home/bcbuser && \
    chmod -R 775 /home/bcbuser

# link to gendev environment
RUN . /home/bcbuser/conda/bin/activate && \
    conda init && \
    conda create -y -p /home/bcbuser/conda/envs/gendev && \
    conda activate /home/bcbuser/conda/envs/gendev && \
    ln -s /home/bcbuser/conda/envs/gendev /BEA/gendev

# LD_LIBRARY_PATH needed for Python to find libraries due to conda env issues
ENV LD_LIBRARY_PATH=/home/bcbuser/conda/envs/gendev/lib:$LD_LIBRARY_PATH

RUN . /home/bcbuser/conda/bin/activate && \
    conda init && \
    conda activate /home/bcbuser/conda/envs/gendev && \
    conda install -y -c conda-forge python==3.12 && \
    conda install -y -c conda-forge tensorflow && \
    conda install -y -c conda-forge pandas && \
    conda install -y -c conda-forge numpy && \
    conda install -y -c conda-forge scipy && \
    conda install -y -c conda-forge pyinstaller && \
    conda install -y -c conda-forge mypy && \
    conda install -y -c conda-forge pylint && \
    conda install -y -c conda-forge flask && \
    conda install -y -c conda-forge waitress && \
    conda install -y -c conda-forge setuptools && \
    conda install -y -c conda-forge tox && \
    conda install -y -c conda-forge pipreqs && \
    conda install -y -c conda-forge matplotlib && \
    conda install -y -c conda-forge pillow && \
    conda install -y -c conda-forge nptyping && \
    conda install -y -c conda-forge jsonpickle && \
    conda install -y -c conda-forge xmltodict && \
    conda install -y -c conda-forge mypy && \
    conda install -y -c conda-forge pandas-stubs && \
    conda install -y -c conda-forge openpyxl && \
    conda install -y -c conda-forge pillow && \
    conda install -y -c conda-forge scanpy && \
    conda install -y -c conda-forge cryptography && \
    conda install -y -c conda-forge scikit-learn && \
    conda clean --all --yes && \
    chown -R :bcb_base_group /home/bcbuser && \
    chmod -R 775 /home/bcbuser

# add universal access to conda
RUN cat /etc/bashrc /bcbsetup/conda.txt >> /bcbsetup/bashrc && \
    cp /bcbsetup/bashrc /etc/bashrc

RUN echo 'RETICULATE_PYTHON="/home/bcbuser/conda/envs/gendev/bin/python3"' >> /usr/lib64/R/etc/Renviron


####
#### Install/Setup Tomcat
####

# install Tomcat 10, set to run as bcbuser
ENV TOMCAT_MAJOR=10 \
    TOMCAT_VERSION=10.1.25 \
    TOMCAT_HOME=/opt/tomcat \
    CATALINA_HOME=/opt/tomcat \
    CATALINA_OUT=/dev/null

RUN curl -jksSL -o /tmp/apache-tomcat.tar.gz https://dlcdn.apache.org/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    mv /opt/apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_HOME} && \
    rm -rf ${TOMCAT_HOME}/webapps/docs && \
    rm -rf ${TOMCAT_HOME}/webapps/ROOT && \
    rm -rf ${TOMCAT_HOME}/webapps/examples && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chown -R :bcb_base_group ${TOMCAT_HOME} && \
    chmod -R 775 /home/bcbuser && \
    ln -s /opt/apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_HOME}

####
#### Customize Tomcat and install WebApp WAR
####

# copy installs with group
# (This is newish to Docker. By default, COPY works as root.)
# (So, these files are owned by root and the group bcb_base_group.)
# copy server.xml to start compression - may need to be merged with above later
COPY --chown=:bcb_base_group --chmod=755 installations/server.xml ${CATALINA_HOME}/conf/server.xml
COPY --chown=:bcb_base_group --chmod=755 installations/web.xml ${CATALINA_HOME}/conf/web.xml

# copy installs (all war files present in artifact directory art_bcbbuilddocs)
# (This is newish to Docker. By default, COPY works as root.)
# (So, these files are owned by root and the group bcb_base_group.)
# destination is dir/ not dir/. because docker insists on being different
COPY --chown=:bcb_base_group --chmod=755 art_bcbbuilddocs/*.war ${CATALINA_HOME}/webapps/

####
#### End of build steps
####

RUN R CMD config --all

RUN ls -l /bcbsetup && \
    java -version && \
    R --version && \
    Rscript -e "installed.packages()"

ENV PATH="/home/bcbuser/conda/bin:$PATH"

## if you want to run Tomcat, here is an example of how to do so.
## first switch to your user who is part of the bcb_base_group. NEVER run Tomcat as root.
## second end with the catalina run command.

# switch from root to bcbuser user
# USER bcbuser
# run catalina/Tomcat
# CMD ["/opt/tomcat/bin/catalina.sh", "run"]

