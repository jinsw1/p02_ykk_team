#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BACKEND_DIR="$SCRIPT_DIR/00_backend"

# apply 순서
LAYERS=(
  "10_network"
  "20_security"
  "25_vpn_key"
  "30_compute"
  "40_edge"
  "45_vpn"
  "50_config"
)

ACTION=${1:-apply}  # 기본값 apply

echo "========================================="
echo " ACTION: $ACTION"
echo "========================================="

run_layer() {
  local dir="$1"
  local action="$2"

  echo ""
  echo "-----------------------------------------"
  echo " $dir : terraform $action"
  echo "-----------------------------------------"
  cd "$SCRIPT_DIR/$dir"
  terraform init -reconfigure
  terraform "$action" -auto-approve
}

if [ "$ACTION" = "destroy" ]; then
  # destroy
  echo ""
  echo "[1/2] Destroying layers ..."

  # 배열을 역순으로 순회
  for (( idx=${#LAYERS[@]}-1 ; idx>=0 ; idx-- )); do
    run_layer "${LAYERS[$idx]}" "destroy"
  done

  echo ""
  echo "[2/2] Destroying backend..."
  cd "$BACKEND_DIR"
  terraform init -reconfigure
  terraform destroy -auto-approve

else
  # apply
  echo ""
  echo "[1/2] Provisioning backend..."
  cd "$BACKEND_DIR"
  terraform init
  terraform apply -auto-approve

  echo ""
  echo "[2/2] Provisioning layers ..."

  for layer in "${LAYERS[@]}"; do
    run_layer "$layer" "apply"
  done
fi

echo ""
echo "========================================="
echo " DONE"
echo "========================================="