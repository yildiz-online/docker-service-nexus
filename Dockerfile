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

RUN groupadd --gid 200 nexus && \
    useradd \
      --system \
      --shell /bin/false \
      --comment 'Nexus Repository Manager user' \
      --home-dir /opt/sonatype/nexus \
      --no-create-home \
      --no-user-group \
      --uid 200 \
      --gid 200 \
      nexus

RUN apk remove wget

RUN chown -R nexus:nexus /opt/sonatype/sonatype-work/nexus3
VOLUME /opt/sonatype/sonatype-work/nexus3
USER nexus
ENV NEXUS_HOME=/opt/sonatype/nexus \
    NEXUS_DATA=/opt/sonatype/sonatype-work/nexus3 \
    NEXUS_CONTEXT='' \
    SONATYPE_WORK=/opt/sonatype/sonatype-work \
    INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=2g -Djava.util.prefs.userRoot=/opt/sonatype/sonatype-work/nexus3/javaprefs"

CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
