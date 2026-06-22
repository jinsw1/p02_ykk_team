#!/bin/bash

set -e

BASE_DIR="$(pwd)/envs"
BACKEND_DIR="$BASE_DIR/0backend"
INFRA_DIR="$BASE_DIR/0infra"

ENV=""
ACTION="apply"

for arg in "$@"; do
  case "$arg" in
    --destroy) ACTION="destroy" ;;
    dev|staging|prod) ENV="$arg" ;;
  esac
done

echo "========================================="
echo " ENV   : ${ENV:-none}"
echo " ACTION: $ACTION"
echo "========================================="

run_layer() {
  local dir="$1"
  local action="$2"

  echo ""
  echo "-----------------------------------------"
  echo " $(basename $dir) : terraform $action"
  echo "-----------------------------------------"
  (
    cd "$dir"
    terraform init -reconfigure
    terraform "$action" -auto-approve
  )
}

if [ -z "$ENV" ]; then
  if [ "$ACTION" = "destroy" ]; then
    echo ""
    echo "[1/2] Destroying infra ..."
    run_layer "$INFRA_DIR" "destroy"

    echo ""
    echo "[2/2] Destroying backend ..."
    run_layer "$BACKEND_DIR" "destroy"

  else
    echo ""
    echo "[1/2] Provisioning backend ..."
    (
      cd "$BACKEND_DIR"
      terraform init
      terraform apply -auto-approve
    )

    echo ""
    echo "[2/2] Provisioning infra ..."
    run_layer "$INFRA_DIR" "apply"
  fi

else
  ENV_DIR="$BASE_DIR/$ENV"

  if [ ! -d "$ENV_DIR" ]; then
    echo "ERROR: $ENV_DIR 디렉토리가 존재하지 않습니다."
    exit 1
  fi

  if [ "$ACTION" = "destroy" ]; then
    echo ""
    echo "[1/1] Destroying $ENV ..."
    run_layer "$ENV_DIR" "destroy"

  else
    echo ""
    echo "[1/1] Provisioning $ENV ..."
    run_layer "$ENV_DIR" "apply"
  fi
fi

echo ""
echo "========================================="
echo " DONE"
echo "========================================="