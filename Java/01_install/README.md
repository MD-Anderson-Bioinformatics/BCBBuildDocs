# Python Install

This is for educational and research purposes only. 

The Dockerfile contains the install for Java, sets up the bash environment for Java usage by the OS and applications that depend on it, such as R.

The Dockerfile uses a Fedora 40 base. (Fedora is stable and upstream of CentOS and RHEL.) Because our project requires Tomcat, Java, Python, and R at different times and combination, we install these applications into a base image rather than using pre-builts.

Search the Dockerfile for "Install/Setup Java 17 with variables".

The first run block installs the Java 17 OpenJDK development and headless packages, calls update-alternatives, and does a cleanup. In general, most Java dependencies are satisfied by this.

```
RUN dnf upgrade -y && \
    dnf -y install java-17-openjdk java-17-openjdk-devel java-17-openjdk-headless && \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-17-openjdk/bin/java 1 && \
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-17-openjdk/bin/javac 1 && \
    update-alternatives --set java /usr/lib/jvm/java-17-openjdk/bin/java && \
    update-alternatives --set javac /usr/lib/jvm/java-17-openjdk/bin/javac && \
    dnf upgrade -y && \
    dnf clean all
```

Then we set the environmental variables related to Java. Adding these variables fixes issue where registering Java with R would succeed, but then the registration would be "lost". We also set LD_LIBRARY_PATH so if a package uses a shared library (so file) that is different from the version installed, it looks in the Java libraries directory for it, before looking at the OS level.

IMPORTANT NOTE: The setting for LD_LIBRARY_PATH makes the *assumption* that there are no previous entries in the that variable. If there are use LD_LIBRARY_PATH=[mypath]:LD_LIBRARY_PATH to incorporate the old path.

```
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
```

A commented related to R: this will be covered in more detail in the R documentation, but this command registers the current Java environment with the R setup.

```
# register Java with R
RUN R CMD javareconf
```

