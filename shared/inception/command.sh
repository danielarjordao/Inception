#!/bin/bash

OUTPUT_FILE="TESTE_SEM_COMENTARIOS.txt"

{
    echo "=== Parando tudo ==="
    cd srcs
    docker compose down -v

    echo -e "\n=== Limpando volumes ==="
    cd ..
    sudo rm -rf /home/dramos-j/data/mariadb /home/dramos-j/data/wordpress
    sudo mkdir -p /home/dramos-j/data/mariadb /home/dramos-j/data/wordpress

    echo -e "\n=== Reconstruindo tudo ==="
    cd srcs
    docker compose build

    echo -e "\n=== Iniciando ==="
    docker compose up -d

    echo -e "\n=== Aguardando 30 segundos ==="
    sleep 30

    echo -e "\n=== Logs do WordPress ==="
    docker logs wordpress

    echo -e "\n=== Status FINAL ==="
    docker ps

    echo -e "\n=== Testando acesso ao WordPress ==="
    curl -k https://localhost 2>&1 | head -20

} > "$OUTPUT_FILE" 2>&1

echo "========================================="
echo "SOLUÇÃO APLICADA!"
echo "Output salvo em: $OUTPUT_FILE"
echo "========================================="
