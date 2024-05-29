#!/bin/bash

function configure(){
    BASE_DIR=$(pwd)/data

    # Criando diretórios com permissões apropriadas
    mkdir -m 755 -p "$BASE_DIR/postgresql/pgdata"
    mkdir -m 755 -p "$BASE_DIR/postgresql/sshkeys"
    chmod 755 "$BASE_DIR/postgresql/sshkeys"
    
    mkdir -m 755 -p "$BASE_DIR/pgbarman/sshkeys"
    chmod 755 "$BASE_DIR/pgbarman/sshkeys"
    
    mkdir -m 755 -p "$BASE_DIR/pgbarman/log"
    mkdir -m 755 -p "$BASE_DIR/pgbarman/backupcfg"
    mkdir -m 755 -p "$BASE_DIR/pgbarman/backups"

    #chmod -R 600 "$BASE_DIR/postgresql/sshkeys"
    #chmod -R 600 "$BASE_DIR/pgbarman/sshkeys"

    # Verifique se ~/.ssh/id_rsa existe e crie se necessário
    if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -b 4096 -t rsa -N '' -f ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
    fi

    # Gerando chaves SSH para PostgreSQL
    ssh-keygen -b 4096 -t rsa -N '' -f "$BASE_DIR/postgresql/sshkeys/id_rsa"
    chmod 600 "$BASE_DIR/postgresql/sshkeys/id_rsa"
    ssh-keygen -f "$BASE_DIR/postgresql/sshkeys/id_rsa" -y >> "$BASE_DIR/postgresql/sshkeys/authorized_keys"

    # Gerando chaves SSH para Barman
    ssh-keygen -b 4096 -t rsa -N '' -f "$BASE_DIR/pgbarman/sshkeys/id_rsa"
    chmod 600 "$BASE_DIR/pgbarman/sshkeys/id_rsa"
    ssh-keygen -f "$BASE_DIR/pgbarman/sshkeys/id_rsa" -y >> "$BASE_DIR/pgbarman/sshkeys/authorized_keys"

    # Adicionando chaves de Barman ao PostgreSQL e vice-versa
    ssh-keygen -f "$BASE_DIR/pgbarman/sshkeys/id_rsa" -y >> "$BASE_DIR/postgresql/sshkeys/authorized_keys"
    ssh-keygen -f "$BASE_DIR/postgresql/sshkeys/id_rsa" -y >> "$BASE_DIR/pgbarman/sshkeys/authorized_keys"
    
    chmod 777 "$BASE_DIR/postgresql/sshkeys/id_rsa"
    chmod 777 "$BASE_DIR/postgresql/sshkeys/id_rsa.pub"
    chmod 777 "$BASE_DIR/postgresql/sshkeys/authorized_keys"

    chmod 777 "$BASE_DIR/pgbarman/sshkeys/id_rsa"
    chmod 777 "$BASE_DIR/pgbarman/sshkeys/id_rsa.pub"
    chmod 777 "$BASE_DIR/pgbarman/sshkeys/authorized_keys"

    # Copiando configuração do Barman
    if [ -f Barman/postgres-source-db.conf ]; then
        cp Barman/postgres-source-db.conf "$BASE_DIR/pgbarman/backupcfg/."
    else
        echo "Erro: Barman/postgres-source-db.conf não encontrado."
        exit 1
    fi
}

function build(){
    docker-compose --compatibility --project-name "postgresql-barman" build --memory 1g --no-cache;
}

function up(){
    docker-compose --compatibility --project-name "postgresql-barman" up -d;
}

function stop(){
    docker-compose --compatibility --project-name "postgresql-barman" stop;
}

function drop(){
    docker-compose --compatibility --project-name "postgresql-barman" down;
}

function drop_hard(){
    docker-compose --compatibility --project-name "postgresql-barman" down --remove-orphans --volumes --rmi 'all' && \
    [ -d "./data" ] && sudo rm -rf ./data;
    docker builder prune -f;
}

function populate(){
    docker exec postgres-source-db psql -U dbadmin -d 'db' -p 5432 -c "$(cat ./Postgres/populate_legal-sector_db.sql)";
}

function seed(){
    docker exec postgres-source-db psql -U dbadmin -d 'db' -p 5432 -c "$(cat ./Postgres/populate_legal-sector_db2.sql)";
}

$1