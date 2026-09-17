#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# Auto-Mode Deployment Script for Linux
# 
# Deploys Auto-Mode + Aikido integration to a Linux system.
# 
# Usage:
#   ./deploy-linux.sh [target-user]
# 
# Example:
#   ./deploy-linux.sh          # Deploy to current user
#   ./deploy-linux.sh leo      # Deploy to user 'leo'
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
TARGET_USER="${1:-$(whoami)}"
TARGET_HOME=$(eval echo "~${TARGET_USER}")
OPENCODE_DIR="${TARGET_HOME}/.config/opencode"
AUTO_MODE_DIR="${OPENCODE_DIR}/plugins/auto-mode"
LOG_DIR="${TARGET_HOME}/.opencode"

# ─── Helpers ──────────────────────────────────────────────────────────────

log() {
  echo -e "${BLUE}[Deploy]${NC} $1"
}

success() {
  echo -e "${GREEN}[Deploy]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[Deploy]${NC} $1"
}

error() {
  echo -e "${RED}[Deploy]${NC} $1"
  exit 1
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    error "$1 is required but not installed."
  fi
}

# ─── Pre-flight Checks ───────────────────────────────────────────────────

log "Running pre-flight checks..."

check_command node
check_command npm
check_command git

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  error "Node.js 18+ required (found $(node --version))"
fi

success "Pre-flight checks passed"

# ─── Create Directories ──────────────────────────────────────────────────

log "Creating directories..."

mkdir -p "${AUTO_MODE_DIR}"
mkdir -p "${LOG_DIR}"
mkdir -p "${OPENCODE_DIR}/agents"

success "Directories created"

# ─── Copy Files ──────────────────────────────────────────────────────────

log "Copying Auto-Mode files..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Core files
cp -v "${SCRIPT_DIR}/plugin.js" "${AUTO_MODE_DIR}/"
cp -v "${SCRIPT_DIR}/integration.js" "${AUTO_MODE_DIR}/"
cp -v "${SCRIPT_DIR}/bash-interceptor.js" "${AUTO_MODE_DIR}/"
cp -v "${SCRIPT_DIR}/setup-hooks.js" "${AUTO_MODE_DIR}/"
cp -v "${SCRIPT_DIR}/pre-commit" "${AUTO_MODE_DIR}/"

# Test files
cp -v "${SCRIPT_DIR}/test.js" "${AUTO_MODE_DIR}/" 2>/dev/null || true
cp -v "${SCRIPT_DIR}/test-integration.js" "${AUTO_MODE_DIR}/" 2>/dev/null || true

# Documentation
cp -v "${SCRIPT_DIR}/README.md" "${AUTO_MODE_DIR}/" 2>/dev/null || true

success "Files copied"

# ─── Copy Agents ─────────────────────────────────────────────────────────

log "Copying agent definitions..."

if [ -d "${SCRIPT_DIR}/../../agents" ]; then
  cp -v "${SCRIPT_DIR}/../../agents/auto-mode.md" "${OPENCODE_DIR}/agents/" 2>/dev/null || true
  cp -v "${SCRIPT_DIR}/../../agents/safety-checker.md" "${OPENCODE_DIR}/agents/" 2>/dev/null || true
fi

success "Agents copied"

# ─── Copy Policy ─────────────────────────────────────────────────────────

log "Copying policy file..."

if [ -f "${SCRIPT_DIR}/../../auto-mode-policy.md" ]; then
  cp -v "${SCRIPT_DIR}/../../auto-mode-policy.md" "${OPENCODE_DIR}/"
elif [ -f "${SCRIPT_DIR}/../auto-mode-policy.md" ]; then
  cp -v "${SCRIPT_DIR}/../auto-mode-policy.md" "${OPENCODE_DIR}/"
fi

success "Policy copied"

# ─── Update opencode.json ────────────────────────────────────────────────

log "Checking opencode.json..."

OPENCODE_JSON="${OPENCODE_DIR}/opencode.json"

if [ -f "${OPENCODE_JSON}" ]; then
  # Check if auto-mode plugin is already configured
  if grep -q "auto-mode/plugin.js" "${OPENCODE_JSON}"; then
    warn "Auto-Mode plugin already in opencode.json — skipping"
  else
    warn "Manual update needed: Add './plugins/auto-mode/plugin.js' to plugin array in ${OPENCODE_JSON}"
  fi
  
  # Check if auto_mode config exists
  if grep -q '"auto_mode"' "${OPENCODE_JSON}"; then
    warn "auto_mode config already exists — verify it includes aikido settings"
  else
    warn "Manual update needed: Add auto_mode configuration to ${OPENCODE_JSON}"
  fi
else
  warn "opencode.json not found at ${OPENCODE_JSON}"
  warn "Create it manually or copy from Windows system"
fi

# ─── Install npm Dependencies ────────────────────────────────────────────

log "Installing npm dependencies..."

cd "${AUTO_MODE_DIR}"
if [ -f "package.json" ]; then
  npm install --production 2>/dev/null || true
else
  # Create minimal package.json
  cat > package.json << 'EOF'
{
  "name": "opencode-auto-mode",
  "version": "1.0.0",
  "description": "Auto-Mode + Aikido integration for OpenCode",
  "main": "plugin.js",
  "dependencies": {}
}
EOF
  npm install --production 2>/dev/null || true
fi

success "Dependencies installed"

# ─── Make Scripts Executable ─────────────────────────────────────────────

log "Setting permissions..."

chmod +x "${AUTO_MODE_DIR}/pre-commit" 2>/dev/null || true
chmod +x "${AUTO_MODE_DIR}/setup-hooks.js" 2>/dev/null || true
chmod +x "${AUTO_MODE_DIR}/bash-interceptor.js" 2>/dev/null || true

success "Permissions set"

# ─── Run Tests ───────────────────────────────────────────────────────────

log "Running tests..."

if [ -f "${AUTO_MODE_DIR}/test.js" ]; then
  cd "${AUTO_MODE_DIR}"
  if node test.js > /dev/null 2>&1; then
    success "Base tests passed"
  else
    warn "Some base tests failed — check ${AUTO_MODE_DIR}/test.js"
  fi
fi

if [ -f "${AUTO_MODE_DIR}/test-integration.js" ]; then
  cd "${AUTO_MODE_DIR}"
  if node test-integration.js > /dev/null 2>&1; then
    success "Integration tests passed"
  else
    warn "Some integration tests failed — check ${AUTO_MODE_DIR}/test-integration.js"
  fi
fi

# ─── Create Desktop Entry (Optional) ─────────────────────────────────────

log "Creating convenience aliases..."

ALIAS_FILE="${TARGET_HOME}/.bashrc"
ALIAS_MARKER="# Auto-Mode aliases"

if grep -q "${ALIAS_MARKER}" "${ALIAS_FILE}" 2>/dev/null; then
  warn "Auto-Mode aliases already in .bashrc — skipping"
else
  cat >> "${ALIAS_FILE}" << 'EOF'

# Auto-Mode aliases
alias auto-mode-test='node ~/.config/opencode/plugins/auto-mode/test.js'
alias auto-mode-integration='node ~/.config/opencode/plugins/auto-mode/test-integration.js'
alias auto-mode-hook-install='node ~/.config/opencode/plugins/auto-mode/setup-hooks.js install'
alias auto-mode-hook-status='node ~/.config/opencode/plugins/auto-mode/setup-hooks.js status'
alias auto-mode-eval='node ~/.config/opencode/plugins/auto-mode/integration.js eval'
EOF
  success "Aliases added to .bashrc"
fi

# ─── Summary ─────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Auto-Mode + Aikido Deployment Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
echo ""
echo "  Installed to: ${AUTO_MODE_DIR}"
echo "  Log file:     ${LOG_DIR}/auto-mode.log"
echo ""
echo "  Next steps:"
echo "    1. Update opencode.json with plugin and auto_mode config"
echo "    2. Install git hooks in your repos:"
echo "       cd /path/to/repo && node ${AUTO_MODE_DIR}/setup-hooks.js install"
echo "    3. Test the installation:"
echo "       node ${AUTO_MODE_DIR}/test.js"
echo "       node ${AUTO_MODE_DIR}/test-integration.js"
echo ""
echo "  Usage:"
echo "    node ${AUTO_MODE_DIR}/integration.js eval 'npm install express'"
echo "    node ${AUTO_MODE_DIR}/bash-interceptor.js run 'git status'"
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"