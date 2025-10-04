#!/bin/bash

START_DIR=$(pwd)


# Переход в директорию с Terraform
cd ./diploma/terraform || { echo "Не удалось перейти в директорию Terraform"; exit 1; }
echo "Запуск terraform УДАЛЯТЬ..."
terraform destroy -auto-approve