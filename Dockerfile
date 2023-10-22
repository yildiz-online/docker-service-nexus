FROM ubuntu:jammy

LABEL maintainer="Grégory Van den Borre vandenborre.gregory@hotmail.fr"

ARG NEXUS_VERSION=3.61.0-02
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

RUN apt-get update && apt-get install -y -q wget

RUN wget --quiet --output-document=/tmp/nexus.tar.gz "${NEXUS_DOWNLOAD_URL}" && \
    mkdir /tmp/sonatype && \
    tar -zxf /tmp/nexus.tar.gz -C /tmp/sonatype && \
    mv /tmp/sonatype/nexus-${NEXUS_VERSION} /opt/sonatype/nexus && \
    rm /tmp/nexus.tar.gz

RUN mv /opt/sonatype/sonatype-work/nexus3 /nexus-data && \
    ln -s /nexus-data /opt/sonatype/sonatype-work/nexus3

RUN sed -i '/^-Xms/d;/^-Xmx/d;/^-XX:MaxDirectMemorySize/d' /opt/sonatype/nexus/bin/nexus.vmoptions
RUN sed -i -e 's/^nexus-context-path=\//nexus-context-path=\/\${NEXUS_CONTEXT}/g' /opt/sonatype/nexus/etc/nexus-default.properties

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

RUN apt-get remove -y -q wget && apt-get -q -y autoremove && apt-get -y -q autoclean

RUN chown -R nexus:nexus /nexus-data
VOLUME /nexus-data
USER nexus
ENV NEXUS_HOME=/opt/sonatype/nexus \
    NEXUS_DATA=/nexus-data \
    NEXUS_CONTEXT='' \
    SONATYPE_WORK=/opt/sonatype/sonatype-work \
    INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=2g -Djava.util.prefs.userRoot=/nexus-data/javaprefs"

CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
