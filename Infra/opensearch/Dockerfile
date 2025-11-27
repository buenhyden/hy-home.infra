FROM opensearchproject/opensearch:latest

LABEL version="0.1" creator="chochyjj@gmail.com" description="Opensearch add plugins"

WORKDIR /usr/share/opensearch/

RUN /usr/share/opensearch/bin/opensearch-plugin install --batch ingest-attachment analysis-nori mapper-annotated-text mapper-murmur3 mapper-size repository-azure discovery-azure-classic

RUN /usr/share/opensearch/bin/opensearch-plugin install https://github.com/aiven/prometheus-exporter-plugin-for-opensearch/releases/download/2.16.0.0/prometheus-exporter-2.16.0.0.zip
