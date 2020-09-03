# DinD with nvidia-docker

Use nvidia-docker inside a container. Forked from https://github.com/hillyu/dind-nvidia-docker.


## Requirements

[nvidia-docker](https://github.com/NVIDIA/nvidia-docker) is required on the host machine.


## Building image

You can either pull the image `henderake/dind:nvidia-docker` or build the image by yourself with the following command:  
```shell
  $ ./build.sh
```


## Running the dind:nvidia-docker container

The usage of the container is the same as the [official dind image](https://hub.docker.com/_/docker), except that you have to run it in a `nvidia` runtime.

Here is an example.
First, run the container on the host machine.
```shell
  $ DIND=$(docker run --privileged --gpus all )
  $ docker exec -it $DIND /bin/bash
```
Now we have a shell in the dind container. Inside this container, you can run any container that requires `nvidia` runtime.

You can also connect a second container to `dind:nvidia-docker`. Refer to [official dind image](https://hub.docker.com/_/docker) to read the steps.


## Acknowledgement
The dind part of this Dockerfile is copied from [https://github.com/docker-library/docker/tree/master/19.03/dind](https://github.com/docker-library/docker/tree/master/19.03/dind)
