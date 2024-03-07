# GitLab CI/CD Image Cleanup

This is for educational and research purposes only. 

This contains an overview of how to clean up the Docker image used as part of the build and test CI/CD process.

Automated cleanup of the CI/CD environment is important, as otherwise the CI/CD server can be filled up with old Docker images that persist and take up disk space. In our case, the Docker images are pushed elsewhere and can (and should) be removed, including the image used for the previous build and unit test step.

# GitLab CI YML

We use the after_script to cleanup, so that in case of an error, the images are still cleaned. A cleanup step at the end of the "script" section gets skipped if there are errors.

The build_image_job portion of the .gitlab-ci.yml appears below.

```
# artifacts (only thing needed here) are carried over
build_images_job:
  # this tells job to only run on tags of the form BCB_*
  # tag used is available in CI_COMMIT_REF_NAME
  only:
    - /^BCB_.*$/
  # tags here refers to docker/shell tags on runners
  tags:
    - shell
  stage: build_images
  script:
    - hostname
    - pwd
    - whoami
    - id
    - env
    - echo $0
    - CUR_DUR_DQS=`pwd`
    - echo ${CUR_DUR_DQS}
    - ls -l ${CUR_DUR_DQS}
    # build MBatch image
    - ${CUR_DUR_DQS}/ci_cd_scripts/build_images.bash "${CUR_DUR_DQS}"
  after_script:
    - CUR_DUR_DQS=`pwd`
    - echo ${CUR_DUR_DQS}
    - ${CUR_DUR_DQS}/ci_cd_scripts/clear_images.bash
```

The "after_script" portion is called in the host server shell after the build is complete. In this case, the after script simply echos a path and then calls a bash script that removes appropriate images.

# Docker Image Cleanup Script

In this case, our cleanup script is simple and straighforward. It gets a list of all images containing a string unique to our process and removes them.

```
docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'my.docker.reg.servername.com')
```

The call to "docker images" with the extra arguments gets the return values in a format usable by "docker rmi".

The grep pulls pulls out images unique to the process or project being cleaned. In this case, we use the Docker Registry to which the images are pushed. Other projects may use a tag or other string to identify cleanable images.

The call to "docker rmi" uses the image names and tags for the removal.

