---
name: voxtype-debug
description: Triages and fixes Voxtype voice-to-text dictation on Omarchy/PT-BR (hotkey/input group, language array, eager/VAD, replacements, output mode, engine/binary swaps). Use when voxtype fails, listens wrong, transcribes PT+EN tech jargon badly, paste/type doesn't land, or config changes seem ignored.
---

# Voxtype Debug (Omarchy · PT-BR + EN tech dictation)

## Quick start

```bash
voxtype status                                        # expect: idle
journalctl --user -u voxtype -n 60 --no-pager | grep -iE "Listening|ERROR|unknown language|VAD|chunks|compiled"
voxtype config schema | grep -A3 "engine:|whisper.language|vad.enabled|eager_processing|output.mode" 
voxtype config schema | grep -A20 "Replacements (text"   # must list every expected key
```

Healthy = `idle` + `Listening for KEY_PAUSE (…) on N device(s)` + **zero** ERROR + replacements listed in schema.

## Workflows

### 1. Triage order (stop at first red)

1. **Crash-loop?** journal repeats `engine requested but not compiled` → engine↔binary mismatch (see REFERENCE §3).
2. **Hotkey dead / `No keyboard device found`** → input group not in session. Stopgap: `sudo setfacl -m u:$USER:rw /dev/input/event*`. Permanent: relogin after `usermod -aG input`.
3. **`unknown language 'pt,en'`** → language written as comma STRING. Must be TOML ARRAY in file: `language = ["pt", "en"]` (CLI `config set` cannot write arrays).
4. **Replacements not firing** → likely inline `replacements = {}` (silently ignored). Only `[text.replacements]` sub-table works; confirm via schema listing count.
5. **Text not arriving** → check journal `Output mode:` + `pasted/Typed` lines. See REFERENCE §4 (paste is dead; type+delay).

### 2. Do NOT waste time here (proven dead ends)

- `voxtype config set whisper.language "pt,en"` — wrong; whisper rejects the literal string.
- Inline `replacements = { … }` in TOML — invisible to the binary.
- `output.mode = "paste"` — wtype synthetic Ctrl+V lands ~1/3 of the time; manual Ctrl+V works (ghostty keybind), synthetic doesn't.
- `output.paste_keys` via `config set` — not in v1.0.1 allowlist (docs main is ahead).
- `eager_processing = true` on GPU/iGPU — creates queue backlog (0 chunks ready, 17s+ tails), triple-word boundary artifacts, EN hallucination tails. Doc: GPU users → single-pass. Keep `false`.
- `language = "auto"` (unconstrained) — slow detect, kills eager, still mangles EN terms.
- Cloud LLM post_process without a key: `agy` hangs (>60s), `gemini` no auth, `opencode run` ignores stdin + 30s timeout. Only Groq-style curl key is viable (~1s).
- cohere via `setup --download --model cohere-…` — CLI rejects it; interactive `voxtype setup model` TUI only. Needs ONNX binary (sudo; warns root writes config to /root). CPU-only here (MIGraphX gated on AVX-512; CPU is AVX2).
- `audio.pause_media = true` — pauses MPRIS → BT sink idles → bluez AVDTP `Suspend: Connection timed out` → EDIFIER transport dies → browser freeze. Keep `false` (see REFERENCE §5).
- Judging quality by `Transcribed:` in journal — replacements may apply after logging; judge by text received in chat + schema listing.

### 3. Known-good stack (this machine: Renoir iGPU/AVX2, EDIFIER W800BT, ghostty)

```toml
engine  = "whisper"                    # model large-v3-turbo, Vulkan+flash
language = ["pt", "en"]                # constrained auto (hand-edited array)
eager_processing = false               # single-pass
[vad] enabled = true                   # Silero; may clip final word after long pause
output: mode = "type", type_delay_ms = 10   # B-drop at ≤5; paste unreliable
hotkey: PAUSE, mode toggle, cancel ESC
audio: pause_media = false
[whisper] initial_prompt = "<domain vocab: font-size, Vue, Branch dev, …>"
[text.replacements] sub-table          # 17 keys; engine-agnostic safety net
```

## Advanced

Full pitfall log, BT/AVDTP recovery commands, binary-swap warnings, latency measurements, test battery phrase → [REFERENCE.md](REFERENCE.md).
