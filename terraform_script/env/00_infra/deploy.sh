#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
MAIN_DIR="$SCRIPT_DIR/main"

ACTION=${1:-apply}  # 기본값 apply

echo "========================================="
echo " ACTION: $ACTION"
echo "========================================="

if [ "$ACTION" = "destroy" ]; then
  # destroy 순서: main -> backend
  echo ""
  echo "[1/2] Destroying main..."
  cd "$MAIN_DIR"
  terraform init -reconfigure
  terraform destroy -auto-approve

  echo ""
  echo "[2/2] Destroying backend..."
  cd "$BACKEND_DIR"
  terraform init -reconfigure
  terraform destroy -auto-approve

else
  # apply 순서: backend -> main
  echo ""
  echo "[1/2] Provisioning backend..."
  cd "$BACKEND_DIR"
  terraform init
  terraform apply -auto-approve

  echo ""
  echo "[2/2] Provisioning main..."
  cd "$MAIN_DIR"
  terraform init -reconfigure
  terraform apply -auto-approve
fi

echo ""
echo "========================================="
echo " DONE"
echo "========================================="