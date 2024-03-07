# GitLab CI/CD Docker builds

This is for educational and research purposes only. 

This contains an overview of building Docker containers as part of the CI/CD process.

# GitLab CI YML

Within the "script" portion of the build_images_job in the gitlab-ci.yml file, the build_images.bash function is called. This script builds and pushes to a registry our Docker image.

# Building Docker

While it is possible to run Docker within Docker and perform the build there, such an environment is delicate and not particularly maintainable. Additionally, there didn't seem to be any real advantage to doing so. Therefore, remember this step is run within a normal shell on the CI/CD server.

The first steps in the build are to switch to the directory with the docker-compose.yml file and the Dockerfile. Note that we build using force-rm to remove broken builds and no-cache to build from fresh images. The latter prevents a "rebuild" that is not using the newest versions available. If the build fails, the job stops.

```
cd ${CUR_DUR_DQS}
echo "build image"
docker compose -f docker-compose.yml build --force-rm --no-cache
```

# Pushing to Docker Registry

Next, the image built is pushed to a registry. The registry is part of the image name in the docker-compose.yml file. If multiple images are declared in the YAML file, all images will be pushed.

```
echo "push to registry"
docker compose -f docker-compose.yml push
```

# Cleanup Reminder

Remember, we use the after_script portion of the job to call the clear_images.bash script to remove all images once we are done with them.

