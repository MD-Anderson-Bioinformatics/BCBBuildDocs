# Building and CI/CD for MDA BCB Batch Effects Projects

These are instructions for building a Docker image using GitLab CI/CD. The Docker image is aimed at building and unit testing bioinformatics software packages, such as MD Anderson's Batch Effects R package MBatch.

Instructions include installs for R, Java, and Python.

All instructions are from the perspective of performing the builds on a Linux system.

This image includes Fedora, R 4+, Python 3, and Java 17. These instructions are a result of MD Anderson Cancer Center Bioinformatics and Computational Biology's Batch Effects effort.

This is for educational and research purposes only. 

Additional information on Batch Effects can be found at [http://bioinformatics.mdanderson.org/main/TCGABatchEffects:Overview](http://bioinformatics.mdanderson.org/main/TCGABatchEffects:Overview).
Downloads and details on Standardized Data are available at [http://bioinformatics.mdanderson.org/TCGA/databrowser/](http://bioinformatics.mdanderson.org/TCGA/databrowser/).

After cloning this repo, this can be built by running, in the directory with Dockerfile:

```
docker build -t bcb_build_docs .
```

---
---
---

# Introduction to CI/CD

This link is a pretty comprehensive introduction to CI/CD [https://www.jetbrains.com/teamcity/ci-cd-guide/](https://www.jetbrains.com/teamcity/ci-cd-guide/).

CI is Continuous Integration - an automated process to pull code releases from a repo and perform builds and testing on the code.
CD is Continuous Deployment - an automated process to similarly pull code releases from a repo and build deployable deliverables. Usually, this includes actual deployment, but in our examples we simply build the Docker containers needed to deploy.

Of note, we make sure the same images are used in development, stage, and production. This makes sure your development and stage tests of the images are still valid once you reach production.

Using Docker and CI/CD together means you have consistent environments, reproducible executables and testing, and images that are directly linked to code repositories.

At the bottom of the page is a summary of general advantages of Docker and CI/CD created by Perplexity.AI.

## Consistent Environments

With properly built Dockerfiles, you can make sure the same version of the operating system, packages, libraries, and code are built into your image. This means when you start processing samples on a project in year 1, you can run the exact same processing on samples in year 5. Also, you can push your Docker image to Docker Hub and share it, so if someone needs to reproduce your results, the same code you used is available to them.

## Reproducible Executables and Testing

By automating builds and testing, you make sure your code is reliable. (Or, at least as reliable as the tests.) And without requiring human intervention in a build, it makes sure that no errors or changes are unintentionally or intentionally introduced.

## Linked to Code Repository

By linking your CI/CD to a tagged version of the repository, it means you can identify exactly what version of the code was used at each point in your project. This makes determining when a sample needs reprocessing to be similar, as well as simplifying tracking down bugs.

---
---
---

# GitLab CI/CD

## Setup for CI/CD

General CI/CD instructions - covers the .gitlab-ci.yml file how and things are configured. Details on installation can be seen in [General_CI_CD/01_setup/README.md](General_CI_CD/01_setup/README.md). 

## Post-Cleanup for CI/CD

Post-build cleanup CI/CD instructions - covers the clear_images.bash script and the after_script keywortd from the .gitlab-ci.yml file. Details on image cleanup are in [General_CI_CD/02_cleanup/README.md](General_CI_CD/02_cleanup/README.md). 

## CI/CD Application Builds and Unit Tests

CI/CD Instructions for building and testing Java and Python Applications within the build_apps.bash and build_copy.bash scripts. Details on build/test process are in [General_CI_CD/03_application_builds/README.md](General_CI_CD/03_application_builds/README.md). 

## CI/CD Docker Builds

CI/CD Instructions for building Docker images within the build_images.bash. Details on build/test process are in [General_CI_CD/04_docker_builds/README.md](General_CI_CD/04_docker_builds/README.md). 

---
---
---

# Python Setup

## Installing Python

Python 3 and related packages are installed via the Dockerfile. Details on installation can be seen in [Python/01_install/README.md](Python/01_install/README.md). 

## Python Unit Tests

Unit testing for Python is described in [Python/02_unit_test/README.md](Python/02_unit_test/README.md).

## Compiling Python with PyInstaller

Compiling Python to create an executable is described in [Python/03_pyinstaller/README.md](Python/03_pyinstaller/README.md).

## Running Python with Waitress

Running a Python Flask application as a PyInstaller executable using Waitress is described in [Python/04_waitress/README.md](Python/04_waitress/README.md).

---
---
---

# Java Setup

## Installing Java

Java 17 OpenJDK packages are installed via the Dockerfile. Details on installation can be seen in [Java/01_install/README.md](Java/01_install/README.md). 

## Java Unit Tests and Compilation

Unit testing and compiling for Java is described in [Java/02_unit_test/README.md](Java/02_unit_test/README.md).

## Running a Java Web Application

Installing and running a Java Web Application under Tomcat 10 is described in [Java/03_tomcat/README.md](Java/03_tomcat/README.md).

---
---
---

# R Setup

## Installing R

R and related packages are installed via the Dockerfile. Details on installation can be seen in [R-java-devel/01_install/README.md](R-java-devel/01_install/README.md). 

## R Unit Tests and Compilation

Unit testing and compiling for R is described in [R-java-devel/02_unit_test/README.md](R-java-devel/02_unit_test/README.md).

---
---
---

# Notes and Discussion

## User for conda

Note that conda is not installed as root. If conda is installed as root, and you use a different version of Python from the base version, system updated quit working. This is because dnf uses Python.

## Building Singularity Image from Docker Image

Generally speaking, because of security concerns (the ability to get root), rather than using Docker, most HPC and similar setups will use Singularity images/containers rather than Docker. The good news is, you can create a Singularity image from a Docker image.

To create a Singularity sif file, we use Docker Registry 2.7. The older version is used as it allows us to do this without needing HTTPS setup.

We first start the Docker Registry. Then we push the image to the registry.

Then run "singularity build" to create the SIF file from the Docker registry. Then we can stop the registry.

```
# start the Docker registry
docker run -d -p 5000:5000 --restart always --name registry registry:2.7

# push your image to the registry
docker push localhost:5000/myimage:VERSION

# build the Singularity SIF image. (sudo may or may not be required, depending on your system)
sudo singularity build --nohttps myimage_VERSION.sif docker://localhost:5000/mbatchhpc/myimage:VERSION

# then you can stop the registry, which wipes out the pushed image
# which is convenient since the registry does not have a convenient way to clear old images
docker stop registry
```

## Benefits of Docker and CI/CD

as per [https://www.perplexity.ai/search/what-are-the-.st4yMglT866MWItmUs6CA?s=u](https://www.perplexity.ai/search/what-are-the-.st4yMglT866MWItmUs6CA?s=u)

The benefits of using Docker in CI/CD (Continuous Integration/Continuous Deployment) pipelines include:

1. **Streamlined Process**: Docker helps streamline the CI/CD process by allowing developers to run tests in parallel and save time on builds[1].
2. **Consistency**: Docker provides consistent, repeatable processes for creating production-like environments, which helps in reducing the "it works on my machine" problem[4].
3. **Isolation**: Docker containers ensure the isolation of applications and their dependencies, which is crucial for testing and deploying applications in a controlled environment[4].
4. **Portability**: Containers are agnostic to the underlying infrastructure, which means they can run on any platform that supports Docker, facilitating easier workload migration and maintaining consistent environments across different stages of development[4].
5. **Efficiency**: Docker images are typically very small, which facilitates rapid delivery and reduces the time to deploy new applications or updates[5].
6. **Error Detection**: CI/CD with Docker can show errors quickly, allowing for faster resolution and ensuring higher quality releases[2].
7. **Cost Savings**: By automating the CI/CD process with Docker, organizations can save time and money that would otherwise be spent on manual processes[2].
8. **Security**: Docker can help build a robust and secure CI/CD pipeline by allowing for easy updates and patches to be applied to containerized applications[4].
9. **Ease of Maintenance**: Using Docker to manage the build environment simplifies maintenance tasks, such as updating to a new version of a programming runtime[3].

Overall, Docker enhances the CI/CD pipeline by improving the reliability, efficiency, and security of the application development and deployment process.

Citations:
[1] [https://www.cigniti.com/blog/need-use-dockers-ci-cd/](https://www.cigniti.com/blog/need-use-dockers-ci-cd/)
[2] [https://www.linkedin.com/pulse/role-docker-cicd-pipeline-md-shoriful-islam](https://www.linkedin.com/pulse/role-docker-cicd-pipeline-md-shoriful-islam)
[3] [https://docs.docker.com/build/ci/](https://docs.docker.com/build/ci/)
[4] [https://amzur.com/blog/ci-cd-pipeline-security-with-dockers](https://amzur.com/blog/ci-cd-pipeline-security-with-dockers)
[5] [https://dzone.com/refcardz/cicd-with-containers](https://dzone.com/refcardz/cicd-with-containers)

## Live Examples

The Batch Effects and MetaBatch projects utilize this setup.

The repo is available at [https://github.com/MD-Anderson-Bioinformatics/BatchEffectsPackage](https://github.com/MD-Anderson-Bioinformatics/BatchEffectsPackage)

You can see the visualization sites at:
[https://bioinformatics.mdanderson.org/MQA/](https://bioinformatics.mdanderson.org/MQA/)
[https://bioinformatics.mdanderson.org/MOB/](https://bioinformatics.mdanderson.org/MOB/)

---
---
---

# Funding

This work was supported in part by:

- U.S. National Cancer Institute (NCI) grant: Weinstein, Broom, Akbani. Computational Tools for Analysis and Visualization of Quality Control Issues in Metabolomic Data, U01CA235510
- U.S. National Cancer Institute (NCI) grant: Akbani, Weinstein, Broom. A Genome Data Analysis Center Focused on Batch Effect Analysis and Data Integration, U24CA264006
- U.S. National Cancer Institute (NCI) grant: Weinstein, Mills, Akbani. Batch effects in molecular profiling data on cancers: detection, quantification, interpretation, and correction, U24CA210949
- U.S. National Cancer Institute (NCI) grant: Weinstein, Broom. "Next Generation" Clustered Heat Maps for Fluent, Interactive Exploration of Omic Data, U24CA199461
- U.S. National Cancer Institute (NCI) grant: Weinstein, Mills, Akbani. Integrative Pipeline for Analysis & Translational Application of TCGA Data (GDAC), U24CA143883
- The Michael & Susan Dell Foundation
- The H.A. and Mary K. Chapman Foundation

