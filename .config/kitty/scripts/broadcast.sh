#!/bin/bash
# ============================================================
# BROADCAST COMMAND TO ALL KITTY WINDOWS
# ============================================================
# Envia um comando para todas as janelas do kitty
# Uso: kitty-broadcast "comando"
# ============================================================

if [ -z "$1" ]; then
    echo "Usage: kitty-broadcast \"command\""
    echo ""
    echo "Example:"
    echo "  kitty-broadcast \"echo hello\""
    echo "  kitty-broadcast \"ls -la\""
    exit 1
fi

COMMAND="$1"

# Send command to all windows
kitty @ send-text --all "$COMMAND"
echo "Broadcasted to all windows: $COMMAND"
