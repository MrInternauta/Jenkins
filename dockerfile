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
    && apt-get install -y iputils-ping \



    