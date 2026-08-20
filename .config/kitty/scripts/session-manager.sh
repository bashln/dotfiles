#!/bin/bash
# ============================================================
# SESSION MANAGER FOR KITTY
# ============================================================
# Gerencia sessions do kitty (criar, salvar, carregar, listar)
# Uso: kitty-session <command> [session-name]
# ============================================================

SESSIONS_DIR="$HOME/.config/kitty/sessions"
Kitty_SOCKET="/tmp/kitty-$USER"

# Ensure sessions directory exists
mkdir -p "$SESSIONS_DIR"

usage() {
    echo "Usage: kitty-session <command> [session-name]"
    echo ""
    echo "Commands:"
    echo "  new <name>      Create a new session"
    echo "  save [name]     Save current session (default: current)"
    echo "  load <name>     Load a session"
    echo "  list            List all sessions"
    echo "  delete <name>   Delete a session"
    echo "  current         Show current session name"
    echo ""
    echo "Examples:"
    echo "  kitty-session new dev"
    echo "  kitty-session save dev"
    echo "  kitty-session load dev"
    echo "  kitty-session list"
    exit 1
}

list_sessions() {
    echo "Available sessions:"
    echo "-------------------"
    for session in "$SESSIONS_DIR"/*.conf; do
        if [ -f "$session" ]; then
            basename "$session" .conf
        fi
    done
}

new_session() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Error: Session name required"
        usage
    fi
    
    local session_file="$SESSIONS_DIR/$name.conf"
    if [ -f "$session_file" ]; then
        echo "Error: Session '$name' already exists"
        exit 1
    fi
    
    # Create empty session file
    touch "$session_file"
    echo "Created session: $name"
    
    # Launch kitty with new session
    kitty @ launch --session "$session_file"
}

save_session() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Error: Session name required"
        usage
    fi
    
    local session_file="$SESSIONS_DIR/$name.conf"
    
    # Save current session state
    kitty @ save-state --session "$session_file" 2>/dev/null || {
        echo "Error: Could not save session. Make sure kitty is running with remote control enabled."
        exit 1
    }
    
    echo "Saved session: $name"
}

load_session() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Error: Session name required"
        usage
    fi
    
    local session_file="$SESSIONS_DIR/$name.conf"
    
    if [ ! -f "$session_file" ]; then
        echo "Error: Session '$name' not found"
        exit 1
    fi
    
    # Load session
    kitty @ launch --session "$session_file"
    echo "Loaded session: $name"
}

delete_session() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Error: Session name required"
        usage
    fi
    
    local session_file="$SESSIONS_DIR/$name.conf"
    
    if [ ! -f "$session_file" ]; then
        echo "Error: Session '$name' not found"
        exit 1
    fi
    
    rm "$session_file"
    echo "Deleted session: $name"
}

current_session() {
    echo "Current session information:"
    kitty @ ls 2>/dev/null || echo "Could not get session info"
}

# Main command handler
case "$1" in
    new)
        new_session "$2"
        ;;
    save)
        save_session "$2"
        ;;
    load)
        load_session "$2"
        ;;
    list)
        list_sessions
        ;;
    delete)
        delete_session "$2"
        ;;
    current)
        current_session
        ;;
    *)
        usage
        ;;
esac
