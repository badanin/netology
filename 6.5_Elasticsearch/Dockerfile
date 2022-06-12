FROM centos:7

COPY elasticsearch-8.2.0-linux-x86_64.tar.gz /opt

RUN adduser elasticsearch \
&& tar xzf /opt/elasticsearch-8.2.0-linux-x86_64.tar.gz -C /opt \
&& rm -f /opt/elasticsearch-8.2.0-linux-x86_64.tar.gz \
&& mv /opt/elasticsearch-8.2.0 /opt/elasticsearch \
&& mkdir -p /var/lib/elasticsearch/{data,logs} \
&& chown -R elasticsearch:elasticsearch /opt/elasticsearch /var/lib/elasticsearch

COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /opt/elasticsearch/config
EXPOSE 9200
EXPOSE 9300
ENV ES_USER=elasticsearch ES_GROUP=elasticsearch
USER elasticsearch:elasticsearch
ENTRYPOINT /opt/elasticsearch/bin/elasticsearch
