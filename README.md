# Description

This sample project demonstrates how to use Clair and Dagda to scan your docker containers before deployment. It uses the GitLab CI/CD pipeline to build, scan, and deploy a tomcat docker container. Note that the tomcat container is only for testing purposes. No production ready container. 

Clair and clair-scanner are tools to check Docker images for known vulnerabilities. Both are open source and aim for static analysis of containers. For more information on both see: [Clair](https://github.com/coreos/clair) and [Clair-Scanner](https://github.com/arminc/clair-scanner).

# Gitlab-CI 

The goal of this sample project is to enable security scanning before pushing a docker image to a container registry. This example is based on the official Gitlab tutorial [Gitlab Clair](https://docs.gitlab.com/ee/ci/examples/container_scanning.html)

The first job is to build a docker image. 

'''
## Build a docker container and pass it to the next stage
build:
  stage: build
  script:
    - docker build -t ${CI_APPLICATION_REPOSITORY}:${CI_APPLICATION_NAME}-${CI_APPLICATION_TAG} . 
    - mkdir image_cache
    - docker save ${CI_APPLICATION_REPOSITORY}:${CI_APPLICATION_NAME}-${CI_APPLICATION_TAG} > image_cache/cached_image.tar    
  artifacts:
    paths:
      - image_cache
'''

In order to use caching and pass the created docker image to the next job, we create a new directory named "image_cache" and sage the created image. Note that this step is required, since we do not have access to /var/lib/docker. The resulting image is stored in image_cache/cached_image.tar

Next, we start the container scanning job. The first task to be done is to load the docker image that has been cached from the build job. Afterwards, we start the clair-scanner. 

'''
# Perform security scan with clair
container_scanning:
  stage: test
  script:
    - docker load -i image_cache/cached_image.tar
    - docker run -d --name db arminc/clair-db:latest
    - docker run -p 6060:6060 --link db:postgres -d --name clair --restart on-failure arminc/clair-local-scan:v2.0.1
    - wget https://github.com/arminc/clair-scanner/releases/download/v8/clair-scanner_linux_amd64
    - mv clair-scanner_linux_amd64 clair-scanner
    - chmod +x clair-scanner
    - touch clair-whitelist.yml
    - while( ! wget -q -O /dev/null http://docker:6060/v1/namespaces ) ; do sleep 1 ; done
    - retries=0
    - echo "Waiting for clair daemon to start"
    - while( ! wget -T 10 -q -O /dev/null http://docker:6060/v1/namespaces ) ; do sleep 1 ; echo -n "." ; if [ $retries -eq 10 ] ; then echo " Timeout, aborting." ; exit 1 ; fi ; retries=$(($retries+1)) ; done
    - ./clair-scanner -c http://docker:6060 --ip $(hostname -i) -r gl-container-scanning-report.json -l clair.log -w clair-whitelist.yml ${CI_APPLICATION_REPOSITORY}:${CI_APPLICATION_NAME}-${CI_APPLICATION_TAG} || true
  artifacts:
    paths: [gl-container-scanning-report.json]
'''

The final result of the scan is presented in the job. 
[](images/Clair-Scanner-Result.PNG)

Note that it is possible to integrate the results in Gitlab merge requests. For more information on how to use this tool see: [Clair-Scanner Gitlab](https://docs.gitlab.com/ee/user/project/merge_requests/container_scanning.html)