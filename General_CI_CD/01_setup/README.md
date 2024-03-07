# GitLab CI/CD Setup

This is for educational and research purposes only. 

This contains an overview of how the .gitlab-ci.yml file is organized and how we do CI/CD at BCB.

# GitLab Documentation for CI/CD

Details on setting up CI/CD in GitLab are well-documented by GitLab. Documentation can be seen at [https://docs.gitlab.com/ee/ci/](https://docs.gitlab.com/ee/ci/). 

# BCB Processing

We use two different steps in CI/CD.

The first step compiles and runs unit tests on applications and code, and builds a job artifact of compiled apps and other files. This step runs within a "build" Docker image, to prevent OS CI Server issues from impacting build requirements.

The second step uses the job artifacts and installs them in a Docker image. This step runs on the server OS, to avoid issues with building Docker images within Docker.

# GitLab GUI and CI/CD Setup

## Server Configuration

Using your CI server, the Docker group and other installs should already be available.

See [https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#runner-configuration](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#runner-configuration) for details.

Setup includes the ability to build and run Docker images.

Your user should be part of the "wheel", docker, and cirunner groups. (The wheel group is the sudo group for RHEL -- your OS may vary.)

Also, if you are using a Docker repository without HTTPS edit /etc/docker/daemon.json to include:

```
"insecure-registries": ["http://your.server:PORT"]
```

Then restart the Docker daemon with:

```
sudo systemctl restart docker
```

The default timeout for CI is 1 hour, found in Settings -> CI/CD -> General pipelines. This can be changed there if needed.

While in general you want unit tests and CI to be quick, we had to increase our timeout because some of the testing requires running statistical analysis which simply take time to perform.

## GitLab CI/CD Configuration

### Fetch vs Clone

In CI/CD Settings under General Pipeline in GitLab for the target repository, change the default "fetch" to "clone". Under default fetch, unless you remove all files at end of CI, files deleted or moved within GitLab will not be removed on the next run.

### Variables

In CI/CD Settings under Variables in GitLab for the target repository, I added one or two variables for use in the pipeline. The CI_FETCH variable is a token used to download from protected repositories as an authenticated user.

### CI Runners

To prepare for CI, we have to register the fact that a CI Runner will be used for a particular project. For these repos, we will register a CI Runner that runs a Docker image every time a submit is done and a CI Runner that uses a shell session. Later, we will add configuration so that work is executed only when specific tags are added.

In GitLab, go to Settings -> CI/CD for your project and expand the Runners section. There should be section titled "Set up a specific Runner manually" -- you need the URL and the token from that section.

Login to your CI server and use the URL and registration token (unique to each repo) to register a Docker runner for that repo. 

The CI Runner that uses a Docker image is registered similar to the below. Obviously all the "your" segments will need to be changed.

Note the "tag-list docker" entry, which tells it to only execute stages marked with the docker tag or the "tag-list shell" entry, which executes using a shell.

It is unfortunate the GitLab overloads the "tag" name in this way. This is especially an issue since the "docker" and "shell" tags are pre-defined executor options in GitLab, and are placed in both tag-list and executor entries.

```
sudo gitlab-runner register -n \
  --url https://your.gitlab.server/ \
  --registration-token YOURregistrationTOKEN \
  --tag-list docker \
  --executor docker \
  --description "CI Compile and Unit Test" \
  --docker-image "your.docker.repo.server:5000/docker_group/docker_image:latest"
```

If there is a problem registering, it may be a certificate issue, if your GitLab uses a self-signed certificate. Get a copy of the certificate and rerun the command, adding the certificate line:

```
  --tls-ca-file gitlab-cert.crt
```

The below example is for registering the shell CI Runner.

```
sudo gitlab-runner register -n \
  --url https://your.gitlab.server/ \
  --registration-token YOURregistrationTOKEN \
  --tag-list shell \
  --executor shell \
  --description "CD Build Image(s)"
```

# .gitlab-ci.yml setup

Build a YAML file named .gitlab-ci.yml and place it into the root directory of your repo. This will be run by the runners registered above.

By convention, in the first line of my GitLab CI YAML files, I put in a comment indicating for which repository this is a CI YAML.

This becomes useful when debugging or comparing files

## GitLab CI File: Variables Section

There are two variables you will probably be interested in using in the YAML file.

The first is GIT_DEPTH - for CI/CD purposes, we are not interested in an exhaustive history of the GitLab repo. Setting the depth to 1 makes sure we just get the top level we want.

The other variable is GIT_SSL_NO_VERIFY. If your internal repo uses a self-signed certificate for HTTPS/SSL, set this to 1 to allow the runner to communicate between the GitLab repo and the CI Server without validating the certificate.

```
variables:
  # do not clone history, just get leaves
  GIT_DEPTH: 1
  # do not do SSL validation
  GIT_SSL_NO_VERIFY: 1
```

## GitLab CI File: Stages Section

Next, the CI YAML file includes a stages section. Stages are run in the order listed. We will call these Stage Names.

We define two stages next. These stages correspond to the two BCB Processing steps above.

The first stage (sometimes called job in GitLab) is named compile_and_test. This is where we compile and do unit tests within a build Docker image.

The second stage is named build_images. This is where the resulting Docker images are built within a shell on the CI Server.

```
stages:
  # stages are run in this order, by the runners assigned to them 
  # registered from the command line, using the tags keyword to 
  # assign docker and shell executors
  # 1. compiles and runs unit tests
  - compile_and_test
  # 2. builds Docker images and pushes to repo
  - build_images
```

## GitLab CI File: Jobs

The next entries are "jobs" -- by convention, I name the jobs with the stage name followed by "_job".

The Docker Executor Job, for the compile_and_test stage, is defined first.

The first part of the job entry describes the job, stage, and how to run it.

I also add a comment indicating which image the runner was registered to use, so the job does not use an image tag.

In the example above "compile_and_test_job" is the job name (based on the stage name).
The next line "only: - /^BCB_.*$/" indicate this job should only be started when a tag of the form "BCB_<something else>" is added to the repository.

To make things confusing the next lines overload the tag word with "tags: - docker", indicating this job has the docker notation tied to the "tags-list" docker entry for the runner.

Finally, "stage: compile_and_test" indicates to which stage this job belongs, in this case, the first stage to be executed.

The next section of the job is the script section. Any portion of the script section with a non-zero exit code is seen as a failure.

We use the CI_COMMIT_REF_NAME to name the artifact.

```
# --executor docker uses an image registered in the GitLab GUI.
# does not need image tag.
compile_and_test_job:
  # this tells job to only run on tags of the form BCB_*
  # tag used is available in CI_COMMIT_REF_NAME
  only:
    - /^BCB_.*$/
  # tags here refers to docker/shell tags on runners
  tags:
    - docker
  stage: compile_and_test
  # everything under script is run in the Docker container
  # fetch/clone is into /builds/BatchEffects_clean/BatchEffectsPackage
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
    - ls -l ${CUR_DUR_DQS}/ci_cd_scripts
    # run build script
    - ${CUR_DUR_DQS}/ci_cd_scripts/build_apps.bash "${CUR_DUR_DQS}"
    # copy files to artifact directory
    - mkdir ${CUR_DUR_DQS}/art_bcbbuilddocs
    - ${CUR_DUR_DQS}/ci_cd_scripts/build_copy.bash "${CUR_DUR_DQS}" "${CUR_DUR_DQS}/art_bcbbuilddocs"
  # use "top-level for repo" directory names for artifact
  # and GitLab CI automatically copies those directories to next job
  artifacts:
    name: ${CI_COMMIT_REF_NAME}
    paths:
      - art_bcbbuilddocs
    expire_in: 1 week
```

The final section of the job is the artifacts section. The artifacts section includes a name, set to be the same as the initiating tag, the paths to be included in the artifact, and how long to keep the artifact.

Some artifact elements are automatically copied to subsequent jobs and will be available for download once the job is complete. Paths without a /some/other/path at the beginning, as used above, are included in the download and propagated to subsequent jobs. Paths with /some/other/path are not propagated. Any path for the artifact must be within the Git clone directory for the repository on which CI is being run. (The directory doesn't have to exist in Git, it just needs to be within the repo path.)

The next section defines the shell executor.

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

The after_script portion is explained in in the next section.


