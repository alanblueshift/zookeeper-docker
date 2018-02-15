
FROM fedora:26

MAINTAINER cybermaggedon

ARG ZOOKEEPER_HASH
ENV ZOOKEEPER_VERSION ${ZOOKEEPER_VERSION:-3.4.10}
ENV ZOOKEEPER_HASH ${ZOOKEEPER_HASH:-eb2145498c5f7a0d23650d3e0102318363206fba}

# Aditional dependencies
RUN dnf install -y wget
RUN dnf install -y java-1.8.0-openjdk
RUN dnf install -y tar

# Download from Apache mirrors instead of archive #9
ENV APACHE_DIST_URLS \
  https://www.apache.org/dyn/closer.cgi?action=download&filename= \
# if the version is outdated (or we're grabbing the .asc file), we might have to pull from the dist/archive :/
  https://www-us.apache.org/dist/ \
  https://www.apache.org/dist/ \
https://archive.apache.org/dist/

RUN set -eux; \
  download_bin() { \
    local f="$1"; shift; \
    local hash="$1"; shift; \
    local distFile="$1"; shift; \
    local success=; \
    local distUrl=; \
    for distUrl in $APACHE_DIST_URLS; do \
      if wget -nv -O "$f" "$distUrl$distFile"; then \
        success=1; \
        # Checksum the download
        echo "$hash" "*$f" | sha1sum -c -; \
        break; \
      fi; \
    done; \
    [ -n "$success" ]; \
  };\
   \
   download_bin "zookeeper.tar.gz" "$ZOOKEEPER_HASH" "zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz"

RUN tar xzf zookeeper.tar.gz -C /tmp/
RUN rm zookeeper.tar.gz
RUN mv /tmp/zookeeper-$ZOOKEEPER_VERSION /usr/local/zookeeper-$ZOOKEEPER_VERSION

RUN echo -e "\n* soft nofile 65536\n* hard nofile 65536" >> /etc/security/limits.conf

# ADD zookeeper-${ZOOKEEPER_VERSION}.tar.gz /usr/local/
# RUN ln -s /usr/local/zookeeper-${ZOOKEEPER_VERSION} /usr/local/zookeeper
# Zookeeper
RUN ln -s /usr/local/zookeeper-${ZOOKEEPER_VERSION} /usr/local/zookeeper

ENV ZOOKEEPER_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOOKEEPER_HOME/bin
COPY zookeeper/* $ZOOKEEPER_HOME/conf/

COPY start-zookeeper /
RUN chown root:root /start-zookeeper
RUN chmod 700 /start-zookeeper

CMD /start-zookeeper

EXPOSE 2181
