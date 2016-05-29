FROM centos:7

MAINTAINER Clecio Varjao <clecio.varjao+docker-subversion-edge@gmail.com>

# from: http://www.collab.net/downloads/subversion
# Look for the direct download links at:
#    https://downloads-guests.open.collab.net/servlets/ProjectDocumentList?folderID=807&expandFolder=807&folderID=801
# reference/credit: https://github.com/mamohr/docker-subversion-edge

ENV JAVA_VERSION 8u92
ENV JAVA_BUILD_VERSION b14
ENV JAVA_URL="http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$JAVA_BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.tar.gz"
ENV JAVA_TMP_FILE="/tmp/jdk-${JAVA_VERSION}-linux-x64.tar.gz"
ENV JAVA_HOME="/opt/java/current"

ENV CSVN_VERSION="5.1.2"
ENV CSVN_URL="https://downloads-guests.open.collab.net/files/documents/61/12821/CollabNetSubversionEdge-5.1.2_linux-x86_64.tar.gz"
ENV CSVN_TMP_FILE="/tmp/csvn.tgz"
ENV RUN_AS_USER="csvn"

RUN yum -y update && \
	yum -y install wget && \
	yum -y install tar && \
  wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "$JAVA_URL" -O "${JAVA_TMP_FILE}"  && \
  mkdir -p "/opt/java/$JAVA_VERSION" && \
  tar -xzf "${JAVA_TMP_FILE}" -C /opt/java && \
  ln -s "$(ls -d /opt/java/jdk*)" /opt/java/current && \
  /opt/java/current/bin/java -version && \
  python --version && \
  wget --no-cookies --no-check-certificate "${CSVN_URL}" -O "${CSVN_TMP_FILE}" && \
    mkdir -p /opt/csvn && \
    tar -xzf "${CSVN_TMP_FILE}" -C /opt/csvn --strip=1 && \
    rm -rf /opt/java/jdk*/*src.zip && \
    rm -rf "${CSVN_TMP_FILE}" && \
    rm -rf "${JAVA_TMP_FILE}"

ADD files /

RUN useradd ${RUN_AS_USER} && \
    chown -R ${RUN_AS_USER}.${RUN_AS_USER} /opt/csvn && \
    cd /opt/csvn && \
    ./bin/csvn install && \
    ./bin/csvn-httpd install && \
    mkdir -p ./data-initial && \
    cp -r ./data/* ./data-initial


EXPOSE 3343 4434 18080

VOLUME /opt/csvn/data

WORKDIR /opt/csvn
USER ${RUN_AS_USER}

ENTRYPOINT ["/opt/csvn/docker-bootstrap.sh"]