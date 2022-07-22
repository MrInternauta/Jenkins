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
docker exec -it -u root 8acbb9bdb2d9 /bin/bash
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
    && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
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
    image: mrinternauta/jenkins-cli
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
## Creating my own Image and jenkins instance
- Execute 
```
docker build -t mrinternauta/jenkins-cli .
```
- Build the compose service
```
docker-compose up -d
```

##  Cadenas de Jobs
Primero instalamos el plugin Parameterized Trigger, igual cómo instalamos anteriormente y reiniciamos.

Luego vamos a crear 2 jobs nuevos:
watchers: En este job, vamos a configure y vamos a “Build after other projects are built” y escribimos y escribimos hello-platzi, sí hello-platzi es successful, quiero que se ejecute watchers.
Y en la parte de executed shell, escribimos : echo “Running after hello-platzi success” y guardamos.
parameterized: Acepta parámetros cuando lo llamo. Marcamos la opción “ This project is parameterized” y en el name escribimos ROOT_ID.
Y en el execute shell: echo “calle with $ROOT_ID” y guardamos.

Y en hello-platzi, en Downstream project, y estos se añaden cuando jenkins se da cuenta que su job tiene una dependencia con otro.
Vamos al configure de hello-platzi y en el execute shell escribimos:
echo “Hello Platzi from $NAME”
Y añadir un build step que se llama : “Trigger/call build on other projects”, y en projects to build escribimos parameterized y le damos en añadir parámetros, luego parámetros predefinidos y escribimos:
ROOT_ID=$BUILD_NUMBER
BUILD_NUMBER es una variable de entorno, que es el valor de esta ejecución y guardamos.

Le damos en “build with parameters” y entramos al console output de parameterized y vemos que la ejecución número tal, fue la que ejecutó a parameterized.
Corre hello-platzi, él llama declarativamente a parameterized e indirectamente a watchers.

Corre los test para esta versión, cuando acabes, mandame esta versión a producción le pasó el id del commit, y se lo pasó a mí job que hace deployment y cuando lo resuelvas me lo despliegas.
El sabe la cadena de ejecuciones que tuvo, y cuál fue el que inició este proceso.
El profe recomienda usar parameterized jobs en vez de watchers, porque cuando uso watchers solo tengo tres opciones mientras que con parameterized jobs tengo más opciones.


## Conectar jobs
para conectar jobs podemos hacerlo de dos formas, basicamente:

una es que un job este escuchando a otro, y en funcion de su estado success, fail etc. se ejecute -> (ejemplo de watchers)

la otra manera es desde un job (padre), llamar a explicitamente a otro job (hijo) para esto es necesario agregar un build step de tipo Trigger/call build on other projects esta opcion tiene la potencialidad de que se puede pasar parametros del job padre al hijo

relay login -k 35156e4b-fc52-4d94-b42f-63569c754af4 -s 7jdA2fZD5f2g && relay forward --bucket forwarding-config-C87yq5 http://localhost:8080/github-webhook/

## ¿Qué es un 'Pipeline'?
Pipelines nos permiten configurar nuestros Jobs con código en lugar de hacerlo en la interfaz visual. En Jenkins los hay de dos maneras: Scripting y Declarative.
##  jenkinsfile Example
```jenkinsfile
pipeline {
  agent any
  tools {
    nodejs 'Node-18.6'
  }

  options {
    timeout(time: 2, unit: 'MINUTES')
  }

  stages {
    stage('Install dependencies') {
      steps {
        sh 'cd 01-jest && npm install'
      }
    }
    stage('Run tests') {
      steps {
        sh 'cd 01-jest && npm run test'
      }
    }
  }
}
```

[See](https://www.jenkins.io/doc/book/pipeline/)

# DevOps (DevOps = Developer Operations)

# Filosofia
 > DevOps constituye una combinación de filosofías culturales, prácticas y herramientas usadas para mejorar los procesos tradicionales de desarrollo de software

 > DevOps no es un rol, **ni **una herramienta; DevOps es una cultura que busca mas colaboración entre los roles de desarrollo y operaciones, ¿por que? Cuando un equipo de desarrollo entrega el proyecto a otro para que lo cuide, es muy facil para ellos por que se desprenden del sistema. Pero lo que busca DevOps es que ambos tengan una responsabilidad compartidad a lo largo de la vida util del software y comparta el mismo dolor del personal de operaciones y asi poder implementar estrategias para simplificar la implementacion o el mantenimiento del sistema y los de operaciones al compartir el mismo dolor del personal de desarrollo puede ayudar a comprender y mejorar todas esas necesidades operativas y ayudarlas a satisfacer.

### ¿Qué es un operador?
- Son los administradores de sistemas, los que se encargan que el sistema y sus dependencias (tanto de hardware como de software) se encuentren funcionando.

- En algunas empresas les llaman sysadmin, son los encargados del data center o servidores que tenga la empresa donde despliegan codigo.

### Partes del DevOps
- Cultura: El cambio de la cultura en una empresa, el deseo de ambos equipos en colaborar.
- Automatización: Poder reproducir infraestructura así como se reproducen bugs. Generar una cultura en la que tanto desarrolladores como operadores automaticen todas sus tareas.
- Medidas: Cuánto toma las metas de ambos equipos. Se mide productividad, cuánto toma un request al API, cuánto se toma un operador en arreglar un incidente en producción, se mide todo.
- Sharing: Mejores herramientas internas compartidas por ambos equipos con el fin de que el código en producción siempre esté en alta calidad y se pueda arreglar lo más rápido posible.
______________
## Containers y ambientes de desarrollo

### Ambientes Homogéneos para Applicaciones
> Una de las maneras de resolver el ““it works in my machine”” es teniendo homogeneidad en todos los ambientes. El ejecutar código en nuestra máquina local debe parecerse lo más posible al ambiente de pruebas y producción.

> Docker es lo recomendado, funciona para todos los sistemas operativos y es reproducible, podemos tener una infraestructura que comparta todo. Las imágenes son reproducibles, programables y la documentación está en el mismo código.


Las máquinas virtuales no son tan portables como los contenedores y suelen tener problemas de instalación en diferentes entornos o sistemas operativos.

### Meanings
- Deploy = Despliegue.
- Deployable = Desplegable.

## Implementación de Dockerfile


Vamos a mostrar cómo usar un Dockerfile y manejar las dependecias para tenerlas lock in, siempre instalar una versión que ya usaste y probaste.

FROM: Busco una imagen de origen y a partir de ahí se monta el container.
WORKDIR: Es recomendable no correr todo el root. Con esto le decimos a Docker cuál va a ser nuestra carpeta de trabajo.
ADD: Es donde indicamos nuestras dependencias como package.json, hace cache de esa capa para no ejecutarla cada que corramos nuestro contenedor. También sirve para copiar, como lo hacemos en la décima línea.
RUN: le decimos a docker que ejecute un comando. En este caso npm install
EXPOSE: Exponemos el puerto 3000
CMD: Acá le decimos a Docker que ejecute este comando al momento de ejecutar nuestro container. En este caso correrá la aplicación.

dockerignore: es casi igual al gitignore, pero para docker.

```dockerfile
FROM node:11.1.0-alpine

WORKDIR /app

ADD package.json package-lock.json /app/
RUN npm install

EXPOSE 3000

ADD . /app

CMD ["node", "index"]
```

[Ver repo Original completo](https://github.com/elbuo8/platzi-scripts)


```dockerfile
FROM node:18

COPY ["package.json", "package-lock.json", "/usr/src/"]

WORKDIR /usr/src

RUN npm install

COPY [".", "/usr/src/"]

EXPOSE 3000

CMD ["node", "index.js"]
```

Para el caso particular vamos a usar un proyecto diferente el cual esta realizado en [NODE-18](https://github.com/mrinternauta/node-18)

- Note COPY is a docker file command that copies files from a local source location to a destination in the Docker container. ADD command is used to copy files/directories into a Docker image.


Con este archivo podemos crear una imagen de dockers
```bash
docker build -t node_app:tag -f dockerfile .
```
RUN
```
docker run -p 3000:3000 mrinternauta/node_app:001
```
## Ambientes Homogéneos para Infraestructura
Podemos hacer infraestructura como código. Tener el equivalente de docker en infraestructura, teniendo la misma configuración en diferentes servidores y regiones, hay varias opciones para realizar esto y una de ellas es Terraform.

Terraform nos permite escribir código ambiguo que puedo correr en AWS en varias regiones y monta la infraestructura igual en todas ellas. Solo debemos pasarle los parámetros y esto nos permitirá escalar nuestras aplicaciones.

### Infrastructure as Code (IaC)
La infraestructura como código (IaC) (en inglés: Infrastructure as Code) permite gestionar y preparar la infraestructura con código, en lugar de hacerlo mediante procesos manuales.

> Con este tipo de infraestructura, se crean archivos de configuración que contienen las especificaciones que esta necesita, lo cual facilita la edición y la distribución de las configuraciones. Asimismo, garantiza que usted siempre prepare el mismo entorno. La IaC codifica y documenta sus especificaciones para facilitar la gestión de la configuración, y le ayuda a evitar los cambios ad hoc y no documentados.

- Podemos ejecutar la misma arquitectura en diferentes versiones/regiones (usa, autralia, etc)
- El codigo se vuelve la documentación
- No tiene que ser terraform


Si quieres montar tu propia arq usa [terraform](https://www.terraform.io/)
_______--
## Pruebas
Sin pruebas no hay confianza
parte fundamental de CI y es hacer pruebas. Sin pruebas no hay confianza.

- Nuestro CI necesita pruebas que debe correr de forma automatizada como test unitarios, test de integración y test de aceptación, mínimo es necesario tener las dos primeras.

- Unit tests usan mocks
Integration tests usan dependencias reales con fixtures
Acceptance tests usan un ambiente con todos los servicios, como si fuera producción.


### Test
- Unit test: Prueba unitaria
pueden utilizarse mocks para simular u omitir el comportamiento de ciertos elementos que no puedan ser probados aquí (conexiones a bases de datos, respuestas de servicios de proveedores en la nube, etc).

- Integration test: Prueba de integración
Las pruebas de integración utilizan dependencias reales con fixtures (como dumps o seeders para las bases de datos, o incluso se puede crear información de forma manual) que no necesariamente deben ser reales, pero deben simular serlo.

- Aceptance test: Prueba de aceptación
Las pruebas de aceptación son desplegadas en un ambiente de staging, que debe ser lo más parecido posible a producción a nivel de estructura de proyecto y de infraestructura en la nube.


- System test: Prueba de Sistema
- Component test: Prueba de Componente

Al implementar estas pruebas, tenemos mucha confianza y garantía de que el código se está comportando bien; si las pruebas no pasan, el código no debe ser desplegado a producción, sea cualquiera de las pruebas, porque las pruebas nos dan confianza.

Para poder desplegar código de manera segura a producción, debemos tener confianza.
_______--
## Integración Continua

![CI](./ci.png)
Con Continuous Integration, se desea probar cada uno de los cambios que reciba el código, cada Pull Request (en una rama diferente), pues si una rama no pasa las pruebas, no habría razón por la cual mezclarla a su rama destino, se puede dañar la versión en producción.

El ciclo comienza con Git, es muy importante que el código esté versionado, debe haber una historia de los cambios, esto es fundamental; y por consiguiente, el código debe estar hospedado en un repositorio remoto

Teniendo ya el código, debemos tener pruebas para ejecutar. Para este paso, se debe contar con un servidor de automatización (Jenkins, por ejemplo). Este servicio descargaría los últimos cambios del repositorio en la(s) rama(s) correspondiente(s), y ejecuta las pruebas unitarias. Si éstas pasan, se continúa con el ciclo; si no, lo rompe. De esta manera, se tiene la confianza de que el sitio en producción se mantendrá estable.

Hasta este punto, tenemos un historial de eventos: Si las pruebas de cierto commit pasaron, si el flujo continuó o se detuvo, sabemos quién realizó cada commit, etc.

Dentro de este mismo flujo, podemos implementar más soluciones aparte de las pruebas unitarias, como una integración con una herramienta de análisis de código.

El punto base con CI mantenemos estable el entorno de producción, mantenemos buenos styles guides y mantenemos código limpio.

La salida de todo CI es un artefacto.
### Continuous Integration y Artifacts
Con Git hacemos que nuestros cambios en el código queden en una historia que podamos probar antes de pasarlo a la rama master, saber que nuestros test estén pasando con éxito sin romper lo que tenemos en master.

Jenkins es nuestro automatizador de pruebas baja la última versión de nuestra rama donde se hizo un cambio y realiza las pruebas que tenemos y si fallan nos previene de romper nuestra rama principal y nos avisa cuáles fueron las pruebas que fallaron para corregirlo.

También podemos hacer un análisis de código, podemos tener algo muy complejo o un estilo que no gusta al equipo y se puede cambiar en esta parte del ciclo y mantenemos style guide bien y código limpio mientras desarrollamos.

Artifacts es nuestra unidad que va a pasar a todos los ambientes, debe ser algo inmutable. Es algo que podemos almacenar por cierta cantidad de tiempo, tal vez un año en caso en de que necesitemos hacer rollback.

- Los integration tests son más productivos, tienen más alcance y tiene más valor.


### Google often suggests a 70/20/10 split: 70% unit tests, 20% integration tests, and 10% end-to-end tests.
[See](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html)
- TDD
Como desarrollador en vias de incluir TDD en sus practicas habituales y de trabajo el mínimo aceptable de tests unitarios es 100%.

Todos los todos los test unitarios de un modulo se desarrollan antes de desarrollar el código, esto tienen mucho mas sentido en la practica que dicho así (o leído).

Decir: “los tests los hago luego” es dejarlo para nunca, porque siempre tendremos que ocuparnos en algo mas!
### Artifacts
El artefacto debe ser la unidad que va a ser desplegada en los ambientes, debe ser algo inmutable.

### Code Coverage
Es muy importante establecer un límite de aceptación en cuanto al porcentaje del Code Coverage, pero no confiarnos de ese porcentaje, y mantener activa la práctica de hacer Code Review, es algo que no puede ser confiado por las pruebas unitarias. Los Code Review son mucho más poderosos, porque: garantiza que nuestros compañeros sepan lo que está sucediendo en los nuevos features del servicio. Siempre debe haber un proceso de Pull Requests Review, y tiene mucho más 
valor que un Code Coverage.
__________
## CI CI CD
![CI/CD](./cicd.png)

- Continuos Integration ( CI )
También llamado integración continua, cómo su nombre lo dice, consta de integrar funcionalidades a los productos de una forma más sencilla.
 
- Continuos Delivery ( CD )
En español entrega continua, es parecido a CI, pero esto automatiza el proceso de añadir codigo a la rama principal, y facilita el deploy a producción.
 
- Continuos Deployment ( CD )
Despliegue continuo va un paso más allá y el despligue a producción ahora es automático. Esto hace que los cambios se vean en minutos!

_____
## Implementación de CI con Jenkins

The issue was I needed to install the Docker Pipeline plugin in Jenkins.

RUN THE PROJECT
## Build the image
```bash
docker build -t mrinternauta/node_app:001 -f Dockerfile .
```

## Run project
```bash
docker run -p 3000:3000 mrinternauta/node_app:001
```
## Run test
```bash
docker run -p 3000:3000 mrinternauta/node_app:001 npm test
```