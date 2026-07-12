FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        kali-linux-headless \
        bash \
        ca-certificates \
        curl \
        git \
        gobuster \
        hydra \
        iputils-ping \
        john \
        net-tools \
        nikto \
        nmap \
        openssh-client \
        procps \
        python3 \
        python3-pip \
        sqlmap \
        tcpdump \
        vim \
        wget \
        whois && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["/bin/bash"]
