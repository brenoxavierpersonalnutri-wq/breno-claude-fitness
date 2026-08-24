#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# instalar.sh · monta o venv do fallback local de transcrição (faster-whisper)
#
# O zip da skill NÃO carrega o venv (218 MB) — quem instala roda isto UMA vez:
#   bash ~/.claude/skills/watch/whisper-local/instalar.sh
#
# O modelo em si baixa sozinho no primeiro uso do transcrever-local.py
# (medium ≈ 3,5 GB no cache ~/.cache/huggingface · tiny ≈ 75 MB).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -x "$DIR/venv/bin/python" ]] && "$DIR/venv/bin/python" -c "import faster_whisper" 2>/dev/null; then
  echo "✓ venv já pronto em $DIR/venv — nada a fazer."
  exit 0
fi

echo "→ criando venv em $DIR/venv"
python3 -m venv "$DIR/venv"
"$DIR/venv/bin/pip" install --quiet --upgrade pip
"$DIR/venv/bin/pip" install --quiet faster-whisper

echo "✓ pronto. Teste rápido (baixa o modelo tiny, ~75 MB):"
echo "  $DIR/venv/bin/python $DIR/transcrever-local.py <video.mp4> --model tiny"
