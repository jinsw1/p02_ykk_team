#!/bin/bash

set -e

BASE_DIR="$(pwd)/envs"
BACKEND_DIR="$BASE_DIR/backend"
INFRA_DIR="$BASE_DIR/infra"
PROD_DIR="$BASE_DIR/prod"
STAGING_DIR="$BASE_DIR/staging"

ACTION="apply"
STAGING=false

for arg in "$@"; do
  case "$arg" in
    --destroy) ACTION="destroy" ;;
    staging) STAGING=true ;;
  esac
done

echo "========================================="
echo " ACTION : $ACTION"
echo " STAGING: $STAGING"
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

if [ "$STAGING" = true ]; then
  if [ "$ACTION" = "destroy" ]; then
    echo "[1/1] Destroying staging ..."
    run_layer "$STAGING_DIR" "destroy"
  else
    echo "[1/1] Provisioning staging ..."
    run_layer "$STAGING_DIR" "apply"
  fi

elif [ "$ACTION" = "destroy" ]; then
  echo "[1/3] Destroying prod ..."
  run_layer "$PROD_DIR" "destroy"

  echo "[2/3] Destroying infra ..."
  run_layer "$INFRA_DIR" "destroy"

  echo "[3/3] Destroying backend ..."
  run_layer "$BACKEND_DIR" "destroy"

else
  echo "[1/3] Provisioning backend ..."
  run_layer "$BACKEND_DIR" "apply"

  echo "[2/3] Provisioning infra ..."
  run_layer "$INFRA_DIR" "apply"

  echo "[3/3] Provisioning prod ..."
  run_layer "$PROD_DIR" "apply"
fi

echo ""
echo "========================================="
echo " DONE"
echo "========================================="