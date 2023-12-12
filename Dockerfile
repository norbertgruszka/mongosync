FROM ubuntu:24.04
WORKDIR /tmp
RUN apt update && apt install -y wget rsyslog-gssapi
RUN wget https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2004-x86_64-1.7.1.tgz && \
tar -xzf mongosync-ubuntu2004-x86_64-1.7.1.tgz && \
cp mongosync-ubuntu2004-x86_64-1.7.1/bin/mongosync /usr/local/bin/ && \
mongosync -v
ENTRYPOINT [ "mongosync", "--cluster0 MONGOSYNC_CLUSTER_0", "--cluster1 MONGOSYNC_CLUSTER_1" ]