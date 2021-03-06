# Dockerfiles for WSO2 Enterprise Integrator #

This section defines the step-by-step instructions to build [CentOS](https://hub.docker.com/_/centos/) Linux based Docker images for multiple profiles
provided by WSO2 Enterprise Integrator 6.4.0, namely:<br>

1. Integrator
2. Micro integrator
3. Business Process
4. Broker
5. MSF4J
6. Analytics Dashboard
7. Analytics Worker

## Prerequisites
* [Docker](https://www.docker.com/get-docker) v17.09.0 or above

## How to build an image and run

##### 1. Checkout this repository into your local machine using the following git command.

```
git clone https://github.com/wso2/docker-ei.git
```

>The local copy of the `dockerfiles/centos` directory will be referred to as `DOCKERFILE_HOME` from this point onwards.

##### 2. Add JDK, WSO2 Enterprise Integrator distribution and required libraries.

- Download [JDK 1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) and
extract into `<DOCKERFILE_HOME>/base/files`.
- Download [WSO2 Enterprise Integrator 6.4.0 distribution](https://wso2.com/integration/) and 
extract into `<DOCKERFILE_HOME>/base/files`.
- Once both JDK and WSO2 Enterprise Integrator distribution are extracted, it should be as follows:
```
<DOCKERFILE_HOME>/base/files/jdk<version>
<DOCKERFILE_HOME>/base/files/wso2ei-6.4.0
```
- Download [MySQL Connector/J](https://downloads.mysql.com/archives/c-j/) v5.1.45 and then copy that to `<DOCKERFILE_HOME>/base/files`,`<DOCKERFILE_HOME>/analytics/dashboard/files`and `<DOCKERFILE_HOME>/analytics/worker/files` folder
- Download [Andes Client](http://maven.wso2.org/nexus/content/groups/wso2-public/org/wso2/andes/wso2/andes-client/3.2.82/) JAR v3.2.82,
[Geronimo JMS Spec](http://maven.wso2.org/nexus/content/groups/wso2-public/org/apache/geronimo/specs/wso2/geronimo-jms_1.1_spec/1.1.0.wso2v1/) JAR v1.1.0.wso2v1 and
[Secure-vault](http://maven.wso2.org/nexus/content/groups/wso2-public/org/wso2/securevault/org.wso2.securevault/1.0.0-wso2v2/) JAR v.1.0.0-wso2v2 <br> to 
`<DOCKERFILE_HOME>/integrator/files`. These libraries are needed for the communication between Integrator <br> and Message Broker.
- If you intend to use the Docker images with Kubernetes clustered product deployments, download the
[Kubernetes membership scheme](http://central.maven.org/maven2/org/wso2/carbon/kubernetes/artifacts/kubernetes-membership-scheme/1.0.5/kubernetes-membership-scheme-1.0.5.jar)
and [dnsjava for DNS lookups](http://central.maven.org/maven2/dnsjava/dnsjava/2.1.8/dnsjava-2.1.8.jar) JAR artifacts and copy them to
`<DOCKERFILE_HOME>/base/files` folder.

>Please refer to [WSO2 Update Manager documentation]( https://docs.wso2.com/display/WUM300/WSO2+Update+Manager)
in order to obtain latest bug fixes and updates for the product.

##### 3. Build the base Docker image.
- For base, navigate to `<DOCKERFILE_HOME>/base` directory. <br>
  Execute `docker build` command as shown below.
    + `docker build -t wso2ei-base:6.4.0-centos .`
        
##### 4. Build Docker images specific to each profile.
- For Integrator, navigate to `<DOCKERFILE_HOME>/integrator` directory. <br>
  Execute `docker build` command as shown below. 
    + `docker build -t wso2ei-integrator:6.4.0-centos .`
- For Micro Integrator, navigate to `<DOCKERFILE_HOME>/micro-integrator` directory. <br>
  Execute `docker build` command as shown below. 
    + `docker build -t wso2ei-micro-integrator:6.4.0-centos .`        
- For Business Process Server, navigate to `<DOCKERFILE_HOME>/business-process` directory. <br>
  Execute `docker build` command as shown below. 
    + `docker build -t wso2ei-business-process:6.4.0-centos .`
- For Message Broker, navigate to `<DOCKERFILE_HOME>/broker` directory. <br>
  Execute `docker build` command as shown below. 
    + `docker build -t wso2ei-broker:6.4.0-centos .`
- For MSF4J, navigate to `<DOCKERFILE_HOME>/msf4j` directory. <br>
  Execute `docker build` command as shown below. 
    + `docker build -t wso2ei-msf4j:6.4.0-centos .`
- For Analytics Dashboard, navigate to `<DOCKERFILE_HOME>/analytics/dashboard` directory. <br>
  Execute `docker build` command as shown below. 
    + `docker build -t wso2ei-analytics-dashboard:6.4.0-centos .`
- For Analytics Worker, navigate to `<DOCKERFILE_HOME>/analytics/worker` directory. <br>
   Execute `docker build` command as shown below. 
     + `docker build -t wso2ei-analytics-worker:6.4.0-centos .`
    
##### 5. Running docker images specific to each profile.
- For Integrator,
    + `docker run -p 8280:8280 -p 8243:8243 -p 9443:9443 wso2ei-integrator:6.4.0-centos`
- For Micro Integrator,
    + `docker run -p 8290:8290 -p 8253:8253 wso2ei-micro-integrator:6.4.0-centos`
- For Business Process Server,
    + `docker run -p 9445:9445  -p 9765:9765 wso2ei-business-process:6.4.0-centos`  
- For Message Broker,
    + `docker run -p 9446:9446 -p 5675:5675 ...all-port-mappings-here... wso2ei-broker:6.4.0-centos` 
- For MSF4J,
    + `docker run -p 9090:9090 wso2ei-msf4j:6.4.0-centos`
- For Analytics Dashboard,
    + `docker run -p 9713:9713 -p 9643:9643 ...all-port-mappings-here... wso2ei-analytics-dashboard:6.4.0-centos`
- for Analytics Worker,
    + `docker run -p 9444:9444 ...all-port-mappings-here... wso2ei-analytics-worker:6.4.0-centos`

##### 6. Accessing management console per each profile.
- For Integrator,
    + `https:<DOCKER_HOST>:9443/carbon`
- For Business Process Server,
    + `https:<DOCKER_HOST>:9445/carbon`
- For Message Broker,
    + `https:<DOCKER_HOST>:9446/carbon`
- For Analytics Dashboard,
    + Business Rules:<br>
    `https://<DOCKER_HOST>:9643/business-rules`
    + Portal:<br>
    `https://<DOCKER_HOST>:9643/portal`
    + Monitoring:<br>
    `https://<DOCKER_HOST>:9643/monitoring`
    
>In here, <DOCKER_HOST> refers to hostname or IP of the host machine on top of which containers are spawned.

## How to update configurations
Configurations would lie on the Docker host machine and they can be volume mounted to the container. <br>
As an example, steps required to change the port offset of Integrator profile using `carbon.xml` is as follows.

##### 1. Stop the integrator container if it's already running.
In WSO2 Enterprise Integrator 6.4.0 product distribution, carbon.xml file for the integrator profile <br>
can be found at `<DISTRIBUTION_HOME>/conf`. Copy the file to some suitable location of the host machine, <br>
referred to as `<SOURCE_CONFIGS>/carbon.xml` and change the offset value under ports to 1.

##### 2. Grant read permission to `other` users for `<SOURCE_CONFIGS>/carbon.xml`
```
chmod o+r <SOURCE_CONFIGS>/carbon.xml
```

##### 3. Run the image by mounting the file to container as follows.
```
docker run 
-p 8281:8281 -p 8244:8244 -p 9444:9444
--volume <SOURCE_CONFIGS>/carbon.xml:<TARGET_CONFIGS>/carbon.xml
wso2ei-integrator:6.4.0-centos
```

>In here, <TARGET_CONFIGS> refers to /home/wso2carbon/wso2ei-6.4.0/conf folder of the container.

## Docker command usage references

* [Docker build command reference](https://docs.docker.com/engine/reference/commandline/build/)
* [Docker run command reference](https://docs.docker.com/engine/reference/run/)
* [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
