FROM  moussavdb/runtime-java:21

LABEL maintainer="Grégory Van den Borre vandenborre.gregory@hotmail.fr"

ARG NEXUS_VERSION=3.61.0-02
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

RUN apk update && apk add wget
RUN mkdir -p /opt/sonatype/nexus

RUN wget --quiet --output-document=/tmp/nexus.tar.gz "${NEXUS_DOWNLOAD_URL}" && \
    mkdir /tmp/sonatype && \
    tar -zxf /tmp/nexus.tar.gz -C /tmp/sonatype && \
    mv /tmp/sonatype/nexus-${NEXUS_VERSION} /opt/sonatype/nexus && \
    rm /tmp/nexus.tar.gz

VOLUME /opt/sonatype/sonatype-work/nexus3
ENV NEXUS_HOME=/opt/sonatype/nexus \
    NEXUS_DATA=/opt/sonatype/sonatype-work/nexus3 \
    NEXUS_CONTEXT='' \
    SONATYPE_WORK=/opt/sonatype/sonatype-work \
    INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=2g -Djava.util.prefs.userRoot=/opt/sonatype/sonatype-work/nexus3/javaprefs"

CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
