#!/bin/bash

echo "Проверка SSH ключей..."

PUBLIC_KEY_PATH="${1:-~/.ssh/id_ed25519.pub}"
PRIVATE_KEY_PATH="${2:-~/.ssh/id_ed25519}"

# Expand paths
PUBLIC_KEY_PATH=$(eval echo $PUBLIC_KEY_PATH)
PRIVATE_KEY_PATH=$(eval echo $PRIVATE_KEY_PATH)

echo "Публичный ключ: $PUBLIC_KEY_PATH"
echo "Приватный ключ: $PRIVATE_KEY_PATH"

if [ ! -f "$PUBLIC_KEY_PATH" ]; then
    echo "❌ Публичный ключ не найден!"
    exit 1
fi

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "❌ Приватный ключ не найден!"
    exit 1
fi

echo "✅ Ключи найдены"
echo "Публичный ключ:"
cat "$PUBLIC_KEY_PATH"
