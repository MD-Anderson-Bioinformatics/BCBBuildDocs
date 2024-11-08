# R-java-devel Install

This is for educational and research purposes only. 

The Dockerfile contains the install for R (R-java-devel). The R-java-devel includes development tools for R (such as those for building packages) and is built with support for using Java via rJava and the "R javareconf" command, explained below.

The Dockerfile uses a Fedora 40 base. (Fedora is stable and upstream of CentOS and RHEL.) Because our project requires Tomcat, Java, Python, and R at different times and combination, we install these applications into a base image rather than using pre-builts.

Search the Dockerfile for "Install/Setup R 4.x+ plus OS packages for MBatch". Also note that the Java install done before this step is also required.

## One: General OS Packages

The first run installs OS requirements - all OS requirements have been rolled up here. Notably, express-generator, which is used to compile Python executables, has an unpatched critical vulnerability as of this writing - do not run this image exposed to outside world. (We only include express-generator in our internal-only firewalled Docker build image. Our run-time image does not use express-generator.

There are many and various packages installed. Notice how often we require the development (-devel) versions of a package.

```
RUN dnf upgrade -y && \
    dnf -y install dnf-plugins-core && \
    dnf -y install libstdc++ ffmpeg-free ffmpeg-free-devel unzip diffutils openssl-devel libxml2-devel cairo-devel libXt-devel udunits2-devel proj-devel geos-devel gdal-devel sqlite sqlite-devel perl-Tk git git-gui ant maven nodejs file wget harfbuzz fribidi harfbuzz-devel fribidi-devel libcurl-devel freetype-devel libpng-devel libtiff-devel libjpeg-turbo-devel tesseract tesseract-devel leptonica-devel cargo poppler-cpp-devel ImageMagick-c++-devel libwebp-devel librsvg2-devel libgit2-devel gsl gsl-devel && \
    dnf upgrade -y && \
    dnf clean all
    npm install -g express-generator
    #####
    ##### IMPORTANT - DO NOT RUN THIS EXPOSED TO OUTSIDE WORLD
    #####
    # express-generator has unpatched critical vulnerability - do not run this image exposed to outside world
```

## Two: TexLive OS Packages

When building HTML/PDF as part of a package install (done in both the build and the run-time images), TexLive is used. Here we install the two required TexLive OS Packages needed.

```
# Install subset of TexLive
RUN dnf upgrade -y && \
    dnf install -y texlive-2023 texlive-framed && \
    dnf upgrade -y && \
    dnf clean all
```

If you use additional portions of TexLive, the code below using the asterix will autoexpand to install all TexLive packages.

```
# Install all TexLive
RUN dnf upgrade -y && \
    dnf install -y texliv* && \
    dnf upgrade -y && \
    dnf clean all
```

## Three: Pandoc OS Packages

Pandoc is also used in generating HTML/PDF files. We install this separately from TexLive, to prevent occasional issues with the environment, and to insulate the large TexLive install layer from the Pandoc layer.

```
# install pandoc after texlive, since it depends on texlive
RUN dnf upgrade -y && \
    dnf -y install pandoc && \
    dnf upgrade -y && \
    dnf clean all
```

## Four: R Install

This step actually installs R, currently 4.x+. Fedora tracks a pretty recent version of R, so the ease of install and update make this worth waiting the short time for new R releases to make it into the upstream feed.

```
# install R 4.x+
RUN dnf upgrade -y && \
    dnf install -y R-java-devel && \
    dnf upgrade -y && \
    dnf clean all
```

## Five: Set Environment Variables

Then we set the environmental LC_ variables in the Renviron file - this makes sure sorting follows the correct rules needed for MBatch and makes code reproducible independent of the locale. Later in the Python section, additional Python related variables are added to the Renviron file.

```
RUN echo 'LC_CTYPE="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_TIME="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_MESSAGES="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_MONETARY="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_PAPER="C"' >> /usr/lib64/R/etc/Renviron && \
    echo 'LC_MEASUREMENT="C"' >> /usr/lib64/R/etc/Renviron
```

## Six: Perform R javareconf

Next, we register Java with R.

```
# register Java with R
RUN R CMD javareconf
```

When you do this, you should see results similar to the one below. If any of the "Java *" paths are empty, that indicates a problem. Please reference the rJava docs for your OS for details as debugging rJava is way beyond the scope of this documentation.

```
(base) [root /]# R CMD javareconf
Java interpreter : /usr/lib/jvm/java-17-openjdk/bin/java
Java version     : 17.0.9
Java home path   : /usr/lib/jvm/java-17-openjdk/
Java compiler    : /usr/lib/jvm/java-17-openjdk/bin/javac
Java headers gen.: /usr/lib/jvm/java-17-openjdk/bin/javac
Java archive tool: /usr/lib/jvm/java-17-openjdk/bin/jar

trying to compile and link a JNI program 
detected JNI cpp flags    : -I/usr/lib/jvm/java-17-openjdk/include -I/usr/lib/jvm/java-17-openjdk/include/linux
detected JNI linker flags : -L/usr/lib/jvm/java-17-openjdk/lib/server -ljvm
using C compiler: 'gcc (GCC) 13.2.1 20231011 (Red Hat 13.2.1-4)'
gcc -I"/usr/include/R" -DNDEBUG -I/usr/lib/jvm/java-17-openjdk/include -I/usr/lib/jvm/java-17-openjdk/include/linux  -I/usr/local/include    -fpic  -O2 -flto=auto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-U_FORTIFY_SOURCE,-D_FORTIFY_SOURCE=3 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -fstack-protector-strong -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1  -m64  -mtune=generic -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer   -c conftest.c -o conftest.o
gcc -shared -L/usr/lib64/R/lib -Wl,-z,relro -Wl,--as-needed -Wl,-z,now -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -specs=/usr/lib/rpm/redhat/redhat-annobin-cc1 -Wl,--build-id=sha1 -o conftest.so conftest.o -L/usr/lib/jvm/java-17-openjdk/lib/server -ljvm -L/usr/lib64/R/lib -lR


JAVA_HOME        : /usr/lib/jvm/java-17-openjdk/
Java library path: /usr/lib/jvm/java-17-openjdk/lib/server
JNI cpp flags    : -I/usr/lib/jvm/java-17-openjdk/include -I/usr/lib/jvm/java-17-openjdk/include/linux
JNI linker flags : -L/usr/lib/jvm/java-17-openjdk/lib/server -ljvm
Updating Java configuration in /usr/lib64/R
Done.
```

