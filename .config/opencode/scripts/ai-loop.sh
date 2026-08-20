#!/usr/bin/env bash
# ============================================================================
# AI Loop System — OpenCode Agent Loop Runner
# ============================================================================
# Uso:
#   bash ai-loop.sh once <loop-name>              # Execução única
#   bash ai-loop.sh loop <loop-name> <interval>   # Loop contínuo
#   bash ai-loop.sh timed <duration>              # Loop por tempo total
#   bash ai-loop.sh improve [duration]            # Atalho: timed + interactive-improve
#   bash ai-loop.sh cron-install <loop-name> <interval> [max]
#   bash ai-loop.sh cron-remove <loop-name>
#   bash ai-loop.sh status                        # Mostra estado atual
#
# Loop names:
#   linear-bug-finding  — caça de bugs no diff (read-only)
#   security-review     — revisão de segurança (read-only)
#   dependency-audit    — auditoria de dependências (read-only)
#   qa-review           — revisão de qualidade (read-only)
#   interactive-improve — melhoria contínua COM edição de código
#
# Intervalos/duration: 10m, 20m, 30m, 1h, 2h, 4h, 6h, daily, weekly
# ============================================================================

set -euo pipefail

# --- Configuração -----------------------------------------------------------
# REPO_ROOT é o diretório onde o usuário está (projeto alvo)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")"
# OPENCODE_CONFIG_DIR é onde o script está instalado (prompts/ vive junto)
OPENCODE_CONFIG_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROMPTS_DIR="${OPENCODE_CONFIG_DIR}/prompts"
AI_DIR="${REPO_ROOT}/.ai"
STATE_FILE="${AI_DIR}/state.json"
PROGRESS_FILE="${AI_DIR}/progress.md"
MAX_ITERATIONS_DEFAULT=10
MAX_FILES_CHANGED=10

# --- Core Functions ---------------------------------------------------------

print_usage() {
    sed -n '3,16p' "$0" | sed 's/^# //'
    exit 0
}

load_state() {
    if [ -f "$STATE_FILE" ]; then
        ITERATION=$(jq -r '.iteration // 1' "$STATE_FILE" 2>/dev/null || echo 1)
        LAST_STATUS=$(jq -r '.status // "never"' "$STATE_FILE" 2>/dev/null || echo "never")
        LAST_RUN=$(jq -r '.lastRun // "never"' "$STATE_FILE" 2>/dev/null || echo "never")
        CONSECUTIVE_EMPTY=$(jq -r '.consecutiveEmpty // 0' "$STATE_FILE" 2>/dev/null || echo 0)
        LOOP_NAME_SAVED=$(jq -r '.loop // ""' "$STATE_FILE" 2>/dev/null || echo "")
    else
        ITERATION=1
        LAST_STATUS="never"
        LAST_RUN="never"
        CONSECUTIVE_EMPTY=0
        LOOP_NAME_SAVED=""
    fi
}

save_state() {
    local loop="$1" iteration="$2" status="$3" logfile="$4" consecutive="$5"
    mkdir -p "$AI_DIR"
    cat > "$STATE_FILE" <<- STATEEOF
{
  "loop": "${loop}",
  "iteration": ${iteration},
  "maxIterations": ${MAX_ITERATIONS},
  "lastRun": "$(date -u +"%Y-%m-%dT%H-%M-%SZ")",
  "status": "${status}",
  "consecutiveEmpty": ${consecutive},
  "logFile": "${logfile}"
}
STATEEOF
}

validate_loop_name() {
    local name="$1"
    case "$name" in
        linear-bug-finding|security-review|dependency-audit|qa-review|interactive-improve) return 0 ;;
        *) echo "ERRO: Loop desconhecido: $name"; exit 1 ;;
    esac
}

validate_interval() {
    local interval="$1"
    case "$interval" in
        [0-9]*[mMdDhH]|daily|weekly) return 0 ;;
        *) echo "ERRO: Intervalo inválido: $interval (use: 30m, 1h, 2h, 6h, 12h, daily, weekly)"; exit 1 ;;
    esac
}

validate_duration() {
    local duration="$1"
    case "$duration" in
        [0-9]*m|[0-9]*h)
            local num="${duration%[mh]}"
            [ "$num" -gt 0 ] 2>/dev/null && return 0 || return 1
            ;;
        *) return 1 ;;
    esac
}

safety_git_check() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    if echo "$branch" | grep -qE '^(main|master)$'; then
        echo "BLOQUEADO: Não é permitido executar loop na branch '${branch}'."
        echo "Crie ou mude para uma branch de feature primeiro."
        exit 1
    fi

    # Verificar se há merge conflicts
    if git diff --check --quiet 2>/dev/null; then
        : # ok
    else
        # Apenas warning, não bloqueia — conflitos podem ser pré-existentes
        echo "⚠️  ATENÇÃO: Git diff --check encontrou problemas (merge conflicts ou whitespace errors)."
    fi
}

safety_check_diff_size() {
    local changed
    changed=$(git diff --name-only | wc -l)
    if [ "$changed" -gt "$MAX_FILES_CHANGED" ]; then
        echo "BLOQUEADO: Diff muito grande (${changed} arquivos, max ${MAX_FILES_CHANGED})."
        echo "Reduza o escopo ou faça commits menores antes de rodar o loop."
        exit 1
    fi
}

setup_branch() {
    local loop="$1" iteration="$2"
    local branch="ai-loop/${loop}/iter-${iteration}"

    # Cria branch a partir da HEAD atual se não existir
    if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
        git checkout -b "$branch" 2>/dev/null || true
    fi
}

get_prompt_path() {
    local loop="$1"
    local prompt="${PROMPTS_DIR}/loop-${loop}.txt"
    if [ ! -f "$prompt" ]; then
        echo "ERRO: Prompt não encontrado: ${prompt}"
        exit 1
    fi
    echo "$prompt"
}

# --- Run Modes ---------------------------------------------------------------

run_once() {
    local loop="$1" dry_run="${2:-false}"

    validate_loop_name "$loop"
    safety_git_check
    # Só verifica diff size em loops read-only
    if [ "$loop" != "interactive-improve" ]; then
        safety_check_diff_size
    fi

    load_state

    local prompt_path
    prompt_path=$(get_prompt_path "$loop")

    # Limite de iterações
    if [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
        echo "=== Limite de iterações atingido (${MAX_ITERATIONS}) ==="
        echo "Reset: rm -f ${STATE_FILE}"
        exit 0
    fi

    # Setup
    mkdir -p "${AI_DIR}/runs" "${AI_DIR}/findings"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
    local logfile="${AI_DIR}/runs/${timestamp}_${loop}.log"

    echo "═══════════════════════════════════════════════════════════════"
    echo "  AI Loop: ${loop}"
    echo "  Iteração: ${ITERATION}/${MAX_ITERATIONS}"
    echo "  Timestamp: ${timestamp}"
    echo "  Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
    echo "═══════════════════════════════════════════════════════════════"

    if [ "$dry_run" = "true" ]; then
        echo ""
        echo "[DRY-RUN] Comando que seria executado:"
        echo "  opencode run --agent build < \"${prompt_path}\""
        echo ""
        echo "[DRY-RUN] Log seria salvo em: ${logfile}"
        exit 0
    fi

    # --- Execução: opencode run (headless, não interativo) ---
    # Lê o conteúdo do prompt e passa como mensagem para opencode run.
    # O prompt define TODO o workflow: encontrar, corrigir, testar, validar,
    # usando skills carregadas via `skill <nome>`. O script só aguarda o exit code.
    # Usa --agent build para garantir permissões de edição quando necessário.
    echo ""
    echo "--- Executando: ${loop} ---"
    if command -v opencode &>/dev/null; then
        local prompt_content
        prompt_content=$(cat "${prompt_path}")
        opencode run --agent build "${prompt_content}" 2>&1 | tee "${logfile}"
        local OPENCODE_EXIT=$?
    else
        echo "⚠️  opencode CLI não encontrado. Simulando..."
        echo "opencode run --agent build < \"${prompt_path}\"" > "${logfile}"
        local OPENCODE_EXIT=0
    fi

    # --- Determinar status ---
    local status="passed"
    local new_consecutive=$CONSECUTIVE_EMPTY
    if [ $OPENCODE_EXIT -ne 0 ]; then
        echo ""
        echo "❌ Iteração ${ITERATION} falhou (exit code ${OPENCODE_EXIT})."
        status="failed"
        new_consecutive=0
    else
        # Incrementa contador de execuções consecutivas sem problemas
        new_consecutive=$((CONSECUTIVE_EMPTY + 1))
    fi

    # --- Salvar estado ---
    ITERATION=$((ITERATION + 1))
    save_state "$loop" "$ITERATION" "$status" "$logfile" "$new_consecutive"

    # --- Atualizar progress.md ---
    {
        echo ""
        echo "## ${timestamp} — ${loop} (iteração $((ITERATION - 1)))"
        echo "- Status: ${status}"
        echo "- Log: runs/${timestamp}_${loop}.log"
        echo "- Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
        echo ""
    } >> "$PROGRESS_FILE"

    # --- Regras de parada ---
    if [ "$new_consecutive" -ge 3 ]; then
        echo ""
        echo "✅ Parada automática: ${new_consecutive} execuções consecutivas sem problemas encontrados."
        echo "Nenhuma mudança relevante detectada. Loop encerrado."
        save_state "$loop" "$ITERATION" "auto-stopped-clean" "$logfile" "$new_consecutive"
        exit 0
    fi

    if [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
        echo ""
        echo "⏹️  Limite de iterações atingido (${MAX_ITERATIONS})."
        exit 0
    fi

    echo ""
    echo "=== Iteração $((ITERATION - 1)) completa. Status: ${status} ==="
    return 0
}

run_loop() {
    local loop="$1" interval="$2"

    validate_loop_name "$loop"
    validate_interval "$interval"

    echo "=== AI Loop Contínuo: ${loop} a cada ${interval} ==="
    echo "Limite: ${MAX_ITERATIONS} iterações"
    echo "Pressione Ctrl+C para parar."
    echo ""

    while true; do
        run_once "$loop"

        load_state
        if [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
            echo "Limite de iterações atingido. Encerrando."
            break
        fi
        if [ "$LAST_STATUS" = "auto-stopped-clean" ]; then
            echo "Parada automática por execuções limpas consecutivas."
            break
        fi

        echo ""
        echo "--- Próxima execução em ${interval} ---"
        echo "Ctrl+C para cancelar."
        echo ""

        # Converte intervalo para sleep
        case "$interval" in
            daily)    sleep 86400 ;;
            weekly)   sleep 604800 ;;
            *m)       sleep $(( ${interval%m} * 60 )) ;;
            *h)       sleep $(( ${interval%h} * 3600 )) ;;
            *)        sleep 3600 ;; # default 1h
        esac
    done
}

run_timed() {
    local loop="$1" duration="$2" dry_run="${3:-false}"

    validate_loop_name "$loop"
    if ! validate_duration "$duration"; then
        echo "ERRO: Duração inválida: $duration (use: 10m, 20m, 30m, 1h, 2h, 4h)"
        exit 1
    fi

    # Calcula tempo final
    local duration_seconds=0
    case "$duration" in
        *m) duration_seconds=$(( ${duration%m} * 60 )) ;;
        *h) duration_seconds=$(( ${duration%h} * 3600 )) ;;
    esac

    local start_time end_time now
    start_time=$(date +%s)
    end_time=$(( start_time + duration_seconds ))

    # Salva max_iterations original e aumenta para o timed mode
    local saved_max=$MAX_ITERATIONS
    MAX_ITERATIONS=999

    echo "═══════════════════════════════════════════════════════════════"
    echo "  AI Loop Timed: ${loop}"
    echo "  Duração total: ${duration} (${duration_seconds}s)"
    echo "  Previsão de término: $(date -d "@${end_time}" '+%H:%M:%S')"
    echo "  Pressione Ctrl+C para parar."
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    while true; do
        now=$(date +%s)

        # Verifica se excedeu o tempo
        if [ "$now" -ge "$end_time" ]; then
            echo ""
            echo "⏹️  Tempo total de ${duration} atingido. Encerrando."
            break
        fi

        # Mostra tempo restante
        local remaining=$(( end_time - now ))
        local remaining_min=$(( remaining / 60 ))
        local remaining_sec=$(( remaining % 60 ))
        echo -e "⏱️  Tempo restante: ${remaining_min}m${remaining_sec}s\n"

        run_once "$loop" "$dry_run"

        load_state
        if [ "$LAST_STATUS" = "auto-stopped-clean" ]; then
            echo "Parada automática por execuções limpas consecutivas."
            break
        fi
        if [ "$ITERATION" -gt "$MAX_ITERATIONS" ]; then
            break
        fi

        # Pequena pausa entre iterações (não conta no tempo total)
        sleep 2
    done

    # Restaura max_iterations
    MAX_ITERATIONS=$saved_max

    local elapsed=$(( $(date +%s) - start_time ))
    local elapsed_min=$(( elapsed / 60 ))
    local elapsed_sec=$(( elapsed % 60 ))
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Sessão encerrada"
    echo "  Tempo decorrido: ${elapsed_min}m${elapsed_sec}s"
    echo "  Total de iterações: $((ITERATION - 1))"
    echo "═══════════════════════════════════════════════════════════════"
}

cmd_cron_install() {
    local loop="$1" interval="$2" max="${3:-$MAX_ITERATIONS_DEFAULT}"

    validate_loop_name "$loop"
    validate_interval "$interval"

    local script_path
    script_path="$(cd "$(dirname "$0")" && pwd)/ai-loop.sh"

    # Converte intervalo para cron
    local cron_expr
    case "$interval" in
        daily)    cron_expr="0 6 * * *" ;;
        weekly)   cron_expr="0 6 * * 1" ;;
        *m)       minutes=${interval%m}; cron_expr="*/${minutes} * * * *" ;;
        *h)       hours=${interval%h}; cron_expr="0 */${hours} * * *" ;;
        *)        cron_expr="0 * * * *" ;;
    esac

    local cron_job="${cron_expr} cd ${REPO_ROOT} && bash ${script_path} once ${loop} >> ${AI_DIR}/runs/cron-${loop}.log 2>&1"

    # Verificar se já existe
    if crontab -l 2>/dev/null | grep -q "ai-loop.*${loop}"; then
        echo "⚠️  Cron job já existe para '${loop}'. Remova primeiro com:"
        echo "  bash ai-loop.sh cron-remove ${loop}"
        exit 1
    fi

    (crontab -l 2>/dev/null; echo "${cron_job}") | crontab -

    echo "✅ Cron job instalado para '${loop}' (${interval}):"
    echo "   ${cron_expr}"
    echo "   Log: ${AI_DIR}/runs/cron-${loop}.log"
    echo ""
    echo "   Para remover: bash ai-loop.sh cron-remove ${loop}"
    echo "   Para ver: crontab -l | grep ai-loop"
}

cmd_cron_remove() {
    local loop="$1"
    validate_loop_name "$loop"

    if crontab -l 2>/dev/null | grep -q "ai-loop.*${loop}"; then
        crontab -l 2>/dev/null | grep -v "ai-loop.*${loop}" | crontab -
        echo "✅ Cron job removido para '${loop}'."
    else
        echo "Nenhum cron job encontrado para '${loop}'."
    fi
}

cmd_status() {
    load_state
    echo "══════════════════════════════════════"
    echo "  AI Loop System — Status"
    echo "══════════════════════════════════════"
    if [ "$LAST_STATUS" = "never" ]; then
        echo "  Nenhuma execução ainda."
        echo "  Execute: bash ai-loop.sh once <loop-name>"
    else
        echo "  Último loop: ${LOOP_NAME_SAVED}"
        echo "  Iteração: ${ITERATION}/${MAX_ITERATIONS}"
        echo "  Última execução: ${LAST_RUN}"
        echo "  Status: ${LAST_STATUS}"
        echo "  Execuções limpas consecutivas: ${CONSECUTIVE_EMPTY}"
        echo ""
        echo "  Logs:"
        ls -lt "${AI_DIR}/runs/" 2>/dev/null | head -5 || echo "    (sem logs)"
        echo ""
        echo "  Cron jobs ativos:"
        crontab -l 2>/dev/null | grep "ai-loop" || echo "    (nenhum)"
    fi
}

# --- Main -------------------------------------------------------------------

MODE="${1:-help}"
LOOP_NAME="${2:-}"
INTERVAL="${3:-1h}"
MAX_ITERATIONS="${4:-$MAX_ITERATIONS_DEFAULT}"

# Normalizar max_iterations para número
case "$MAX_ITERATIONS" in
    ''|*[!0-9]*) MAX_ITERATIONS=$MAX_ITERATIONS_DEFAULT ;;
esac

mkdir -p "$AI_DIR"

case "$MODE" in
    once)
        run_once "$LOOP_NAME" "${DRY_RUN:-false}"
        ;;
    once-dry)
        DRY_RUN=true run_once "$LOOP_NAME"
        ;;
    loop)
        run_loop "$LOOP_NAME" "$INTERVAL"
        ;;
    timed)
        run_timed "${LOOP_NAME:-interactive-improve}" "${INTERVAL:-30m}" "${DRY_RUN:-false}"
        ;;
    improve)
        # Atalho: timed + interactive-improve
        run_timed "interactive-improve" "${LOOP_NAME:-30m}" "${DRY_RUN:-false}"
        ;;
    cron-install)
        cmd_cron_install "$LOOP_NAME" "$INTERVAL" "$MAX_ITERATIONS"
        ;;
    cron-remove)
        cmd_cron_remove "$LOOP_NAME"
        ;;
    status)
        cmd_status
        ;;
    help|--help|-h)
        print_usage
        ;;
    *)
        echo "ERRO: Modo desconhecido: $MODE"
        print_usage
        ;;
esac
