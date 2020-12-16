FROM moussavdb/runtime-java:8

LABEL maintainer="Grégory Van den Borre vandenborre.gregory@hotmail.fr"

RUN apt update && apt install -y curl
ARG NEXUS_ARCHIVE=nexus.tar.gz

RUN curl -L https://download.sonatype.com/nexus/3/latest-unix.tar.gz --output $NEXUS_ARCHIVE
RUN tar -xvzf $NEXUS_ARCHIVE

RUN rm $NEXUS_ARCHIVE
RUN apt purge -y curl libcurl4 libnghttp2-14 librtmp1 libssh-4

RUN groupadd -g 200 nexus
RUN useradd -g 200 -l -M -s /bin/false -u 200 nexus

RUN chown -R nexus:nexus /sonatype-work

USER nexus

CMD [ "/nexus-3.29.0-02/bin/nexus", "run" ]
