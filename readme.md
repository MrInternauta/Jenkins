# Introducción a Automatización y Jenkis

Al automatizar podemos repetir procesos y tener mayor productividad

## Qué es Jenkins?

Jenkins es un servidor de automatización open source escrito en Java.

## Qué podemos automatizar?

Podemos automatizar cualquier cosa que sea programable

## Caracteristicas

- Es Open Source
- Es el más usado
- Mayormente se corre en Linux
- Escrito en Java
- Es portable
- Es extensible (puedes usar plugins y agregar más funciones)
- Tiene una gran comunidad
- Es amigable y flexible
- Permite escalar vertical-horizontal (Agregando más hardward - horizontal - slaves agregar maquinar virtuales y fisicas)
- Contante innovación
- Es seguro
- CircleCI realiza lo mismo que jenkins en forma de servicio.
- Jenkins funciona o puede trabajar funcionar internamente
- Se puede automatizar con codigo y con interfaz

> También nos permite escalar de manera horizontal y verticalmente, puede correr un sin número de trabajos concurrentemente en una sola máquina y si esa máquina no da abasto se le puede dar más recursos a Jenkins. O una máquina no es suficiente entonces Jenkins nos permite escalar horizontalmente con ““slaves”” y controlar varios nodos para que trabajen por él.

> Jenkins siempre esta siendo innovado y teniendo actualizaciones de seguridad, esto es importante porque es el target más grande de seguridad de una empresa porque lo tiene todo.

> Algo que Jenkins ha trabajado mucho en los últimos años es que puedes escribir tus ““jobs”” o unidades de trabajo en código. Nosotros queremos que nuestra automatización también sea programática, no solo los comando a ejecutar sino poder migrar nuestro trabajo a un nuevo Jenkins de manera reproducible. Han creado Pipelines as code

## Instalación y Configuración Básica de Jenkins

- [How to install jenkins](https://www.jenkins.io/doc/book/installing/)
- [How to install jenkins with dockers](https://www.jenkins.io/doc/book/installing/docker/)
  > Docker is a platform for running applications in an isolated environment called a "container" (or Docker container). Applications like Jenkins can be downloaded as read-only "images" (or Docker images), each of which is run in Docker as a container. A Docker container is in effect a "running instance" of a Docker image.
- If copying and pasting the command snippet above does not work, try copying and pasting this annotation-free version her

```
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2
```

To ensure Jenkins is securely set up by the administrator, a password has been written to the log (not sure where to find it?) and this file on the server:

/var/jenkins_home/secrets/initialAdminPassword

```
docker run -d -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts
```

- Enter as root

```
docker exec -it -u root 351b742fd4d1 /bin/bash
```

## Configuración de un Job

- Descripcion: ayuda a resolver cuando tienes un monton de jobs para describir.

- Discard old builds: ayuda a resolver cuando muchas cosas se llenan en tu disco duro
- Days to keep builds: 365 dias --> quiero tener este build por un año
- Max # of builds to keep: 2 —> guardar los ultimos dos builds

- This project is parameterized: Le puedes pasar parametros al build
  Add Parameter -> String Parameter
- Name: NAME
- Default Value: Felipe
- Description: Descripcion
- Disable this project: sumamente importante, si algo sale mal en un job y quieres que nadie lo corra (La mayor parte de jobs corren automaticos)

### Source Code Management

- Git: Añadir un repositorio
- Credentials: Credenciales
  (Usaremos un script para ejecutar esta parte)

### Build Triggers

(Estuvimos ejecutando a mano)

- Trigger builds remotely (e.g., from scripts): Tienes para correrlo por una API
- Build after other projects are built: Si termino de ejecutar job A quiero correr job B, unicamente si job A fue estable.
- Build periodically: Acepta la sintaxis de un CRON jobs (Corre cada minuto cada X dia, ‘si queremos que algo se ejecute sabado en la noche me corres este JOB’)
- GitHub hook trigger for GITScm polling: Vamos usar futuramente, cuando tengamos un push en Github el job se va ejecutar

### Build Environment

- Delete workspace before build starts: (Importante que lo marquen) si tu corres tu job y modificas tu job y dejas files (algo) en la proxima ejecucion va estar. Queremos que el subfolder este limpio.
- Use secret text(s) or file(s): Para añadir secretos

### Bindings

Llaves o variables de entorno o algo que no deberia estar expuesto a otros usuarios te permite guardarlo y accesarlo atraves de script.

- Abort the build if it’s stuck: Si el job que va a correr toda su vida, porque paso algo. (Si el job fallo o el S.O. fallo)
- Timeout minutes: 3 --> Si paso 3 minutos que cancele el build y falle (Poner como una variable global por comando)
  Add timestamps to the Console Output: Marcar para ver el tiempo de ejecucion en consola
  Build
- Command: echo “Hello platzi $NAME”

- Run with timeout: Si un comando demora mas, si un comando tarda demasiado le permites una ventaja mas de tiempo
  Archive the artifacts: Vamos a usar en el futuro, watch others jobs y que se ejecute.

## ¿Cómo Jenkins interactúa con su máquina local?

- Install node from curl on ubuntu
  If sudo is not installed, install sudo package using the following command:
  ` apt-get install sudo`

```
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

- Dockerfile de node + jenkins
  [See more](https://hub.docker.com/r/jenkis/jenkins)

```
FROM jenkins/jenkins

USER root

RUN apt-get install -y curl \
  && curl -sL https://deb.nodesource.com/setup_11.x | bash - \
  && apt-get install -y nodejs \
  && curl -L https://www.npmjs.com/install.sh | sh

USER jenkins
```

- Dockerfile y el docker-compose
  Contiene node, npm, angular [See more](https://hub.docker.com/r/devopsggq/jenkins)
- **Dockerfile**

```
FROM jenkinsci/jenkins:lts
USER root
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y git
RUN apt-get install -y curl \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && curl -L https://www.npmjs.com/install.sh | sh \
    && npm install -g @angular/cli@latest

USER jenkins
```

- **Docker-Compose**

```
version: '3'

services:
  jenkins:
    image: devopsggq/jenkins:latest
    container_name: jenkins-ci
    privileged: true
    user: root
    ports:
      - 7001:8080
      - 50000:50000
    volumes:
      - ./jenkins_home/:/var/jenkins_home
      - ./jenkins_var/var/run/docker.sock:/var/run/docker.sock
      - ./jenkins_usr/usr/local/bin/docker:/usr/local/bin/docker
```
