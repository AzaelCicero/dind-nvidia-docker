ARG CUDA_IMAGE=nvidia/cuda
FROM ${CUDA_IMAGE}

ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -q && \
    apt-get install -yq \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"  && \
    apt-get update -q && apt-get install -yq docker-ce docker-ce-cli containerd.io &&\
    rm -rf /var/lib/apt/lists/*

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN set -eux; \
    apt-get update -q && \
	apt-get install -yq \
        zsh \
		btrfs-progs \
		e2fsprogs \
		iptables \
		xfsprogs \
		xz-utils \
# pigz: https://github.com/moby/moby/pull/35697 (faster gzip implementation)
		pigz \
		wget && \
    rm -rf /var/lib/apt/lists/*


# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -x \
	&& addgroup --system dockremap \
	&& adduser --system -ingroup dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT ed89041433a031cafc0a0f19cfe573c31688d377

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind


##### Install nvidia docker #####
# Add the package repositories
RUN curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
    apt-key add - && \
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
      tee /etc/apt/sources.list.d/nvidia-docker.list && \
    apt-get update -qq && \
    apt-get install -yq nvidia-docker2 && \
    sed -i '2i \ \ \ \ "default-runtime": "nvidia",' /etc/docker/daemon.json &&\
    rm -rf /var/lib/apt/lists/*

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
