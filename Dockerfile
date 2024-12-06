FROM eclipse-temurin:17-jre-noble AS downloader
ARG NEXUS_VERSION=3.75.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

RUN apt update && apt install -y wget
RUN wget --quiet --output-document=/tmp/nexus.tar.gz "${NEXUS_DOWNLOAD_URL}" && \
    mkdir /tmp/sonatype && \
    tar -zxf /tmp/nexus.tar.gz -C /tmp/sonatype && \
    mv /tmp/sonatype/nexus-${NEXUS_VERSION} /tmp/sonatype/nexus && \
    rm /tmp/nexus.tar.gz

FROM eclipse-temurin:17-jre-noble

LABEL org.opencontainers.image.revision="-"
LABEL org.opencontainers.image.source="https://github.com/yildiz-online/docker-service-nexus"

COPY --from=downloader /tmp/sonatype /opt/sonatype
RUN \
    mv /opt/sonatype/sonatype-work/nexus3 /nexus-data && \
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

RUN chown -R nexus:nexus /nexus-data

VOLUME /nexus-data
EXPOSE 8081
USER nexus

ENV NEXUS_HOME=/opt/sonatype/nexus \
    NEXUS_DATA=/nexus-data \
    NEXUS_CONTEXT='' \
    SONATYPE_WORK=/opt/sonatype/sonatype-work \
    INSTALL4J_ADD_VM_PARAMS="-Xms1200m -Xmx1200m -XX:MaxDirectMemorySize=2g -Djava.util.prefs.userRoot=/nexus-data/javaprefs"

CMD ["/opt/sonatype/nexus/bin/nexus", "run"]
