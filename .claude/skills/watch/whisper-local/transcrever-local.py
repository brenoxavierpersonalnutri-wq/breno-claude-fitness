#!/usr/bin/env python
"""Transcrição LOCAL pra skill watch — faster-whisper, sem chave de API.

Mesmo motor que a cortes-tiktok-turbo usa (faster-whisper · int8 · CPU).
O áudio nunca sai da máquina.

Uso:
  venv/bin/python transcrever-local.py <video-ou-audio> [--model medium] [--start MM:SS] [--end MM:SS]

Saída: linhas "[MM:SS] texto" no stdout — o formato que a watch entrega pro Claude.
Aceita vídeo direto (mp4/mov/webm) ou áudio; decodifica via PyAV, sem ffmpeg manual.
Primeira execução de cada modelo baixa os pesos (~1,5 GB no medium, ~75 MB no tiny).
"""
import argparse
import sys
from pathlib import Path


def hms(s: float) -> str:
    m, sec = divmod(int(s), 60)
    h, m = divmod(m, 60)
    return f"{h}:{m:02d}:{sec:02d}" if h else f"{m:02d}:{sec:02d}"


def parse_ts(t: str) -> float:
    parts = [float(p) for p in t.split(":")]
    while len(parts) < 3:
        parts.insert(0, 0.0)
    return parts[0] * 3600 + parts[1] * 60 + parts[2]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("media")
    ap.add_argument("--model", default="medium",
                    help="tiny/base/small/medium/large-v3 (padrão: medium, o mesmo da cortes-tiktok-turbo)")
    ap.add_argument("--lang", default="pt")
    ap.add_argument("--start", default=None, help="MM:SS — só transcreve a partir daqui")
    ap.add_argument("--end", default=None, help="MM:SS — para aqui")
    args = ap.parse_args()

    media = Path(args.media)
    if not media.exists():
        print(f"erro: {media} não existe", file=sys.stderr)
        return 1

    from faster_whisper import WhisperModel

    print(f"· modelo {args.model} (int8, CPU) · {media.name}", file=sys.stderr)
    model = WhisperModel(args.model, device="cpu", compute_type="int8")

    kwargs = {"language": args.lang, "vad_filter": True}
    clip = None
    if args.start or args.end:
        clip = (parse_ts(args.start) if args.start else 0.0,
                parse_ts(args.end) if args.end else None)

    segments, info = model.transcribe(str(media), **kwargs)

    n = 0
    for seg in segments:
        if clip:
            if seg.end < clip[0]:
                continue
            if clip[1] is not None and seg.start > clip[1]:
                break
        print(f"[{hms(seg.start)}] {seg.text.strip()}")
        n += 1

    print(f"· {n} segmentos · idioma detectado: {info.language} "
          f"(prob {info.language_probability:.0%})", file=sys.stderr)
    return 0 if n else 2


if __name__ == "__main__":
    sys.exit(main())
