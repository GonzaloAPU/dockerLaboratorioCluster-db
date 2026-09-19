FROM postgres:17-bookworm

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    curl && \
    pip3 install --break-system-packages --no-cache-dir \
    "patroni[psycopg3,etcd3]" && \
    rm -rf /var/lib/apt/lists/*

COPY patroni.yml /etc/patroni/patroni.yml

RUN chown postgres:postgres /etc/patroni/patroni.yml

USER postgres

ENTRYPOINT ["patroni", "/etc/patroni/patroni.yml"]