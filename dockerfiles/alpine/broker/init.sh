#!/bin/sh
# ------------------------------------------------------------------------
# Copyright 2018 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------
set -e

# product profile
server_profile=broker

# volume mounts
config_volume=${WORKING_DIRECTORY}/wso2-config-volume
artifact_volume=${WORKING_DIRECTORY}/wso2-artifact-volume
deployment_volume=${WSO2_SERVER_HOME}/wso2/${server_profile}/repository/deployment

# original deployment artifacts
original_deployment_artifacts=${WORKING_DIRECTORY}/wso2-tmp/deployment

# a grace period for mounts to be setup
echo "Waiting for all volumes to be mounted..."
sleep 5

verification_count=0
verifyMountBeforeStart()
{
  if [ ${verification_count} -eq 5 ]
  then
    echo "Mount verification timed out"
    return
  fi

  # increment the number of times the verification had occurred
  verification_count=$((verification_count+1))

  if [ ! -e $1 ]
  then
    echo "Directory $1 does not exist"
    echo "Waiting for the volume to be mounted..."
    sleep 5

    echo "Retrying..."
    verifyMountBeforeStart $1
  else
    echo "Directory $1 exists"
  fi
}

verifyMountBeforeStart ${config_volume}
verification_count=0
verifyMountBeforeStart ${artifact_volume}

# capture Docker container IP from the container's /etc/hosts file
docker_container_ip=$(awk 'END{print $1}' /etc/hosts)

# check if the WSO2 non-root user home exists
test ! -d ${WORKING_DIRECTORY} && echo "WSO2 Docker non-root user home does not exist" && exit 1

# check if the WSO2 product home exists
test ! -d ${WSO2_SERVER_HOME} && echo "WSO2 Docker product home does not exist" && exit 1

# if a deployment_volume is present and empty, copy original deployment artifacts to server...
# copying original artifacts to ${WORKING_DIRECTORY}/wso2-tmp/deployment was already done in the Dockerfile
# these artifacts will be copied to deployment_volume if it is empty, before the server is started
if test -d ${original_deployment_artifacts}; then
    if [ -z "$(ls -A ${deployment_volume}/)" ]; then
	    # if no artifact is found under <WSO2_SERVER_HOME>/wso2/broker/repository/deployment; copy originals
        echo "Copying original deployment artifacts from temporary location to server..."
        cp -R ${original_deployment_artifacts}/* ${deployment_volume}/
    fi
fi

# copy any configuration changes mounted to config_volume
test -d ${config_volume}/ && cp -RL ${config_volume}/* ${WSO2_SERVER_HOME}/
# copy any artifact changes mounted to artifact_volume
test -d ${artifact_volume}/ && cp -RL ${artifact_volume}/* ${WSO2_SERVER_HOME}/

# make any node specific configuration changes
# set the Docker container IP as the `localMemberHost` under axis2.xml clustering configurations (effective only when clustering is enabled)
sed -i "s#<parameter\ name=\"localMemberHost\".*<\/parameter>#<parameter\ name=\"localMemberHost\">${docker_container_ip}<\/parameter>#" ${WSO2_SERVER_HOME}/wso2/${server_profile}/conf/axis2/axis2.xml
# set the Docker container IP as the Apache Thrift server host IP
sed -i "s#<thriftServerHost>.*</thriftServerHost>#<thriftServerHost>${docker_container_ip}</thriftServerHost>#" ${WSO2_SERVER_HOME}/wso2/${server_profile}/conf/broker.xml

# start WSO2 Carbon server
sh ${WSO2_SERVER_HOME}/bin/${server_profile}.sh
