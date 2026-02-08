#!/bin/bash

create_user() {
    local USER=$1
    local GROUP=$2
    local CLUSTER_NAME=${3:-$(kubectl config current-context | cut -d'@' -f2 | cut -d'/' -f1)}

    if [ -z "$CLUSTER_NAME" ]; then
        echo "Не удалось определить имя кластера"
        exit 1
    fi

    echo "Создание пользователя $USER для группы $GROUP в кластере $CLUSTER_NAME"

    # Генерация ключа и CSR
    openssl genrsa -out "${USER}.key" 2048
    openssl req -new -key "${USER}.key" \
        -out "${USER}.csr" \
        -subj "//CN=${USER}\O=${GROUP}"

    # Проверка наличия CA
    if [ ! -f "/etc/kubernetes/pki/ca.crt" ] || [ ! -f "/etc/kubernetes/pki/ca.key" ]; then
        echo "CA файлы не найдены. Использую самоподписанный сертификат (ограниченная функциональность)"
        openssl x509 -req -in "${USER}.csr" \
            -signkey "${USER}.key" \
            -out "${USER}.crt" \
            -days 365
    else
        echo "Использую CA Kubernetes"
        openssl x509 -req -in "${USER}.csr" \
            -CA /etc/kubernetes/pki/ca.crt \
            -CAkey /etc/kubernetes/pki/ca.key \
            -CAcreateserial \
            -out "${USER}.crt" \
            -days 365
    fi

    # Добавление пользователя в kubeconfig
    kubectl config set-credentials "${USER}" \
        --client-certificate="${USER}.crt" \
        --client-key="${USER}.key"

    # Создание контекста
    kubectl config set-context "${USER}-context" \
        --cluster="${CLUSTER_NAME}" \
        --namespace=default \
        --user="${USER}"

    # Очистка временных файлов (опционально)
     rm -f "${USER}.csr" "${USER}.crt" "${USER}.key"
}

set -e

echo "Creating Kubernetes users..."

create_user "devops" "devops"
create_user "developer-ecom" "developers"
create_user "developer-hcs" "developers"

echo "finish"