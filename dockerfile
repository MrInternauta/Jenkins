FROM jenkins/jenkins:lts
USER root
RUN apt-get update -y
RUN apt-get upgrade -y
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \ 
    && apt-get install -y build-essential \
    && apt-get install -y git \
    && npm install -g @angular/cli@latest \
    && apt-get install wget \
    && wget -O /usr/local/bin/relay https://storage.googleapis.com/webhookrelay/downloads/relay-linux-amd64 \
    && chmod +x /usr/local/bin/relay \
    && apt-get install -y iputils-ping
RUN apt-get update -y
RUN apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update -y
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
RUN usermod -aG docker jenkins
RUN service docker start

    