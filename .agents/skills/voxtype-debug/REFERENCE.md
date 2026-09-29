# Voxtype Debug — Reference (session log distilled)

Machine: Omarchy/Arch, Hyprland, AMD Cezanne (Renoir, AVX2-only), ghostty, EDIFIER W800BT (A2DP), webcam mic (SPCA2281) + jack mic (ALC897), voxtype-bin 1.0.1 (AUR), models: base.en / small / large-v3-turbo / cohere-transcribe-q4f16.

## §1 What broke, why, fix (root causes)

| Symptom | Root cause | Fix |
|---|---|---|
| Hotkey dead, `No keyboard device found in /dev/input/` | not in `input` group; user manager caches groups at login (restarts don't reload) | `sudo usermod -aG input $USER` + relogin; stopgap `sudo setfacl -m u:$USER:rw /dev/input/event*` (expires at reboot; group takes over) |
| `whisper_lang_id: unknown language 'pt,en'` | `config set` stores comma STRING; whisper needs single code or voxtype array | file edit: `language = ["pt", "en"]` — docs call this "constrained auto-detect (recommended for multilingual)" |
| Replacements never fire | inline `replacements = {}` not parsed (schema/CLI show empty); even `config set` rewrite NUKED the inline keys | `[text.replacements]` sub-table with bare/quoted keys; verify `voxtype config schema \| grep -A20 Replacements` |
| `unknown config key 'output.paste_keys'` | installed schema allowlist behind docs(main) | hand-edit file; if binary ignores field, fall back |
| Paste never lands (1 success : 2 fails) | voxtype sends synth Ctrl+V via wtype; ghostty keybind works for MANUAL presses only (timing/focus) | `output.mode = "type"`; ghostty manual paste: stock `shift+insert` + added `keybind = control+v=paste_from_clipboard` |
| First char drops ("Branch"→"ranch") | wtype typing race at low delay (1→5 still failed once) | `type_delay_ms = 10` |
| Eager tails17s+, `0 chunks`, "React React React", EN hallucination tail ("To me, I have to need you") | iGPU decodes a5s chunk in7-18s → queue never drains during recording; boundary dedup fails; EN-allowed mode hallucinates on trailing silence | `eager_processing = false` (doc: not recommended with GPU; single-pass more consistent) + VAD on |
| Full `language = "auto"` slow + still wrong | per-chunk detect cost; EN terms still PT-ified | constrained array `["pt","en"]` |
| YouTube/BT freeze after dictation | `pause_media=true` → MPRIS pause → sink idle → bluez AVDTP Suspend timeout → `connect(): Connection refused` loop | `pause_media = false`; old wireplumber fix `session.suspend-timeout-seconds=0` + `bluez5.auto-connect` at `~/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf` (NOT in dotfiles git) |
| Cohere: `Cohere engine requested but voxtype was not compiled with --features cohere` crash-loop | binary symlink switched off cohere-capable variant while `engine=cohere` in config | set `engine=whisper` first, then `sudo voxtype setup gpu --enable` / `onnx --disable` |
| VAD clipped final word ("main"→"me") | segment ended after last pause; threshold0.5 | keep (prefer hallucination-free); replacement net `"virou me" = "virou main"` |

## §2 Language & accuracy facts (PT + EN code-switch)

- Stock whisper in single-`pt` mode destroys embedded EN jargon: width→Wither/ídice, Vue→View/Viu, branch→brante/ranche, font-size→font-side, main→mundo. Research: stock whisper struggles with code-switching without fine-tunes.
- `["pt","en"]` constrained auto = biggest single win (width, font-size, overflow hidden, Branch dev, Outlook all correct after).
- Cohere: `language` = single ISO code only (no auto/list) → forced `pt` wrecked code-switch ("parente deve ir ao cidade de Roma" ← "branch dev virou main"). Good pure-PT prose though. CPU-only on this box.
- `initial_prompt` (whisper-only, inactive on other engines): domain vocab list bias; put failing words there first — it works (Branch, font-size landed).
- Replacements = engine-agnostic, applied after journal log; keep table small (17), only confirmed recurrences. Phrase keys safer than words ("prefiro view" not "view").
- Latency (single-pass, turbo, Vulkan, VAD): ~3.5-7.5s tail for10-30s dictations. small A/B (measured):25.7s audio → **2.33s** tail BUT quality collapsed — "noivo mandou Outlook"→"nós vou mandar um alt-loop", "small"→"esmol", replacement keys miss on inserted articles ("prefiro o view"). **Decision: keep `large-v3-turbo`** — sweet spot of the ladder; `medium` dominated here (full32 layers = slower than turbo on this iGPU, accuracy ≤ turbo); `large-v3` not worth ~3× latency. Escape hatch: `secondary_model = "small"` + `model_modifier = "LEFTSHIFT"` for speed when needed. eager never helped on this iGPU.
- Trailing EN hallucination ("There's a domain") = whisper on silence with EN allowed; VAD fixed it.

## §3 Binary / engine matrix

- Variants: `voxtype-vulkan` (whisper+GPU — DEFAULT), `voxtype-avx2`, `voxtype-onnx-avx2` (parakeet/moonshine/sensevoice/paraformer/dolphin/omnilingual/cohere), CPU avx512, onnx-cuda*, onnx-migraphx (latter need AVX-512 → unusable here).
- Switch: `sudo voxtype setup gpu --enable|disable`, `sudo voxtype setup onnx --enable|disable` (root warns: models/config paths for root differ; user config untouched by those commands but `engine` key must match new binary BEFORE restart).
- cohere download: ONLY interactive `voxtype setup model` TUI → Cohere section → `q4f16` (1500MB, pt included). CLI `setup --download --model cohere-*` = `Unknown model`.
- Engine keys: `voxtype config set engine cohere|whisper`; restart required always (`config set` prints hint; NO hot reload).
- Keep `engine = whisper` unless deliberately testing; dormant engines documented here.

## §4 Output modes verdict

| Mode | Verdict |
|---|---|
| `type` delay≤5 | delivers every time; occasional first-char drop after space+Shift |
| `type` delay10 | **current** — no drops observed |
| `paste` (wl-copy + synth ctrl+v) | clipboard step OK (`Text pasted…` logged) but synth key often lost; do not use |
| `clipboard` | manual only (extra step) |

Ghostty: paste = `shift+insert` (stock) or `control+v` (added keybind, `paste_from_clipboard`). Keep both for manual pastes.

## §5 Bluetooth freeze playbook

1. Identify: journal `avdtp.c … Suspend: Connection timed out`, `spa.bluez5 … Failure in Bluetooth audio transport`, `connect(): Connection refused`.
2. Recover: `bluetoothctl disconnect CC:14:BC:5D:CC:3C; sleep2; bluetoothctl connect CC:14:BC:5D:CC:3C` → look for `fd ready`. Still dead: `systemctl --user restart wireplumber`.
3. Prevent: `pause_media = false` (root trigger was voxtype); keep wireplumber `suspend-timeout-seconds =0` + auto-connect conf.
4. Never re-enable `pause_media` "just to test" without playing YouTube on BT.

## §6 Post-process (LLM cleanup) — status

- Doc hook: `[output.post_process] command = …` (stdin→stdout, fail-open on error/timeout).
- Rejected candidates: `agy -p` (hangs, ignores stdin even w/ `--input-format text`), `gemini -p` (no GEMINI_API_KEY / not logged in), `opencode run` (positional-args only, ~30s, session overhead).
- Viable: Groq free key + curl script (~0.8-1.5s) — needs user signup `console.groq.com/keys`. Wire as `postprocess.sh` with timeout + passthrough-on-fail. Use only if grammar/self-correction errors ("não vejo… não pode") start costing more than1s/dictation.

## §7 Test battery (verbatim)

> "O width do site usa font-size em verde oliva, overflow hidden, prefiro Vue, noivo mandou Outlook e o branch dev virou main"

Check: width, font-size, Vue, Branch dev/main, Outlook; no EN tail garbage; no repeated words; text types itself; tail ≤ ~7s.

Long-form: wedding-project paragraph (PT prose + embedded jargon) — judge agent-readiness, not perfection.
