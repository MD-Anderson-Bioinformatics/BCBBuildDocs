# Python Compilation with PyInstaller

This is for educational and research purposes only. 

The GitLab CI/CD compile job (compile_and_test_job) has a bash script that calls mvn to compile a Java application.

This WAR file is saved in a pipeline artifact, for use during the CI/CD image built job. The directory used for creating artifacts is specified in the "artifacts" portion of the .gitlab-ci.yml file.

```
  # use "top-level for repo" directory names for artifact
  # and GitLab CI automatically copies those directories to next job
  artifacts:
    name: ${CI_COMMIT_REF_NAME}
    paths:
      - art_bcbbuilddocs
    expire_in: 1 week
```

The path to art_bcbbuilddocs is passed to the BASH script, where the WAR file is copied into the artifact directory.

```
echo "copy JavaHelloWorld"
cp ${BASE_DIR}/JavaHelloWorld/target/*.war ${DEST_DIR}/JavaHelloWorld.war
```

After the compilations and tests complete successfully, GitLab CI/CD will run the job to build the Docker image (build_images_job). Within the Dockerfile for this image, Tomcat is installed. Look for "Install/Setup Tomcat" in the Dockerfile. We install Tomcat separately, because it lets us control what OS variant we want (Fedora), allows us to install it as accessible by any member of the bcb_base_group, and works with our need for other installs (R, Java, and Python).

NOTE: Before doing builds, you will need to check the CDN link to make sure the current Tomcat is available. Apache, when they switched to CDN for distribution, only keep the newest version available.

```
# install Tomcat 10, set to run as bcbuser
ENV TOMCAT_MAJOR=10 \
    TOMCAT_VERSION=10.1.13 \
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
```

Next in the Dockerfile, Tomcat is customized and the WAR deployed. Tomcat is owned by root, but the group is our generic group bcb_base_group.

```
# copy installs with group
# (This is newish to Docker. By default, COPY works as root.)
# (So, these files are owned by root and the group bcb_base_group.)
# copy server.xml to start compression - may need to be merged with above later
COPY --chown=:bcb_base_group --chmod=775 installations/server.xml ${CATALINA_HOME}/conf/server.xml
COPY --chown=:bcb_base_group --chmod=775 installations/web.xml ${CATALINA_HOME}/conf/web.xml

# copy installs (all war files present in artifact directory art_bcbbuilddocs)
# (This is newish to Docker. By default, COPY works as root.)
# (So, these files are owned by root and the group bcb_base_group.)
# destination is dir/ not dir/. because docker insists on being different
COPY --chown=:bcb_base_group --chmod=775 art_bcbbuilddocs/*.war ${CATALINA_HOME}/webapps/
```

To run Tomcat, create your own Docker image from this one and for the last two lines switch to your user and then start Tomcat.

```
## if you want to run Tomcat, here is an example of how to do so.
## first switch to your user who is part of the bcb_base_group. NEVER run Tomcat as root.
## second end with the catalina run command.

# switch from root to bcbuser user
USER <your-user>
# run catalina/Tomcat
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
```

