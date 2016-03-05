# Dockerfile to create a WSO2 Enterprise Service Bus
#
# Usage:
#
 

 

# Base image
FROM centos:centos7

MAINTAINER George Zhai <zzff@hotmail.com>

RUN yum -y update
RUN yum -y install unzip
# Install Oracle JDK

ADD assets/_downloads/JDK/jdk-7u79-linux-x64.tar.gz /opt/
RUN ln -s /opt/jdk1.7.0_79 /opt/java
ENV HOME /root
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/java/bin
ENV JAVA_HOME /opt/java


# Install WSO2 product
ENV WSO2_BUNDLE_NAME=wso2esb-4.9.0
ENV WSO2_FOLDER_NAME=wso2esb490v1


# Copy, unzip and remove WSO2 zip to/of container
COPY assets/_downloads/WSO2/${WSO2_BUNDLE_NAME}.zip /opt/
# Disable the next line and enable the above one if you have downloaded and copied the ZIP file manually.
#RUN wget -q -P /opt https://s3-us-west-2.amazonaws.com/wso2-stratos/${WSO2_BUNDLE_NAME}.zip
RUN unzip /opt/${WSO2_BUNDLE_NAME}.zip -d /opt/ > /opt/${WSO2_FOLDER_NAME}.listfiles
RUN mv /opt/${WSO2_BUNDLE_NAME} /opt/${WSO2_FOLDER_NAME}
RUN rm /opt/${WSO2_BUNDLE_NAME}.zip


# Copy WSO2 custom config files to container
#   Modifications in 'carbon.xml': Offset, ServerName, additional ServerRole
COPY assets/_files/${WSO2_FOLDER_NAME}/repository/conf/carbon.xml /opt/${WSO2_FOLDER_NAME}/repository/conf/carbon.xml

 
#   Modifications in 'web.xml': SessionTimeout 600mins

COPY assets/_files/${WSO2_FOLDER_NAME}/repository/conf/tomcat/carbon/WEB-INF/web.xml /opt/${WSO2_FOLDER_NAME}/repository/conf/tomcat/carbon/WEB-INF/web.xml


# Carbon ports (Offset +0)

EXPOSE 9443 9763 8243 8280

 

# Expose WSO2 repository folder to Host
VOLUME ["/opt/${WSO2_FOLDER_NAME}/repository/deployment/server"]
VOLUME ["/opt/${WSO2_FOLDER_NAME}/repository/components/dropins"]
VOLUME ["/opt/${WSO2_FOLDER_NAME}/repository/components/lib"]
VOLUME ["/opt/${WSO2_FOLDER_NAME}/repository/resources/security"]
 

# Working Directory in Container
WORKDIR /opt/${WSO2_FOLDER_NAME}/bin/

# Start WSO2
CMD sh ./wso2server.sh