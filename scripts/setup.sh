#!/usr/bin/env bash
# Gera e compila o Metal Slug X Recompiled a partir do disco do proprio usuario.
# Uso: bash scripts/setup.sh "/caminho/para/Metal Slug X (USA).cue" [--sem-aot]
#   --sem-aot  pula a pre-compilacao das fases (instala mais rapido, mas o jogo
#              trava um pouco na primeira vez que cada trecho aparece)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

AOT=1
[[ "${2:-}" == "--sem-aot" ]] && AOT=0
if [[ $AOT -eq 1 ]]; then T=7; else T=5; fi

CUE="${1:-}"
if [[ -z "$CUE" || ! -f "$CUE" ]]; then
    echo "erro: informe o caminho do arquivo .cue do Metal Slug X (USA)." >&2
    echo "uso: bash scripts/setup.sh \"/caminho/Metal Slug X (USA).cue\"" >&2
    exit 1
fi
CUE="$(cd "$(dirname "$CUE")" && pwd)/$(basename "$CUE")"

# python3 no Windows costuma ser um atalho da Microsoft Store que nao funciona.
PY=""
for c in python3 python py; do
    if command -v "$c" >/dev/null 2>&1 && "$c" -c "import sys; sys.exit(sys.version_info < (3, 9))" >/dev/null 2>&1; then
        PY="$c"; break
    fi
done
if [[ -z "$PY" ]]; then
    echo "erro: Python 3.9+ nao encontrado. Instale com: winget install Python.Python.3.12" >&2
    exit 1
fi

echo "== [1/$T] Baixando submodulos (psxrecomp + recomp-ui) =="
git submodule update --init --recursive

echo "== [2/$T] Preparando o compilador (baixa o toolchain Clang na primeira vez, ~209 MB) =="
TC_BIN="$("$PY" -c "
import sys; from pathlib import Path
sys.path.insert(0, 'psxrecomp/tools')
import toolchain_pack as tp
print(tp.ensure_toolchain(Path('.').resolve(), download=True, log=lambda m: print(m, file=sys.stderr)))
" | tail -n 1 | tr -d '\r')"
if [[ -z "$TC_BIN" ]]; then
    echo "erro: nao foi possivel preparar o toolchain." >&2
    exit 1
fi
TC_BIN="$(cygpath -u "$TC_BIN" 2>/dev/null || echo "$TC_BIN")"
export PSXRECOMP_TOOLCHAIN_DIR="$(dirname "$TC_BIN")"
export PATH="$TC_BIN:$PATH"
echo "toolchain: $PSXRECOMP_TOOLCHAIN_DIR"

echo "== [3/$T] Compilando o recompilador =="
bash psxrecomp/tools/ci/build_emitters.sh

echo "== [4/$T] Gerando o codigo C a partir do seu disco =="
"$PY" psxrecomp/psxrecomp_cli.py generate --config game.toml --project-root . --disc "$CUE"

echo "== [5/$T] Compilando o jogo =="
"$PY" psxrecomp/psxrecomp_cli.py rebuild --config game.toml --project-root . \
    --build-dir build-release --no-pgo

if [[ $AOT -eq 1 ]]; then
    # Os trechos de cada fase sao carregados do disco durante o jogo. Pre-compila-los
    # agora evita as travadas da primeira vez que cada trecho aparece.
    mkdir -p aot-work
    CLANG="$TC_BIN/clang.exe"
    [[ -f "$CLANG" ]] || CLANG="$TC_BIN/clang"
    # Cada compilacao usa ate ~700 MB de RAM: limita o paralelismo.
    JOBS="$(nproc 2>/dev/null || echo 4)"
    (( JOBS > 6 )) && JOBS=6

    echo "== [6/$T] Detectando as fases no seu disco =="
    "$PY" psxrecomp/tools/aot_overlay_spike/extract_generic.py \
        --game-toml game.toml --recompiler build-recompiler/psxrecomp-game.exe \
        --disc "$CUE" --out aot-work/disc-records.json --tmp aot-work/extract

    echo "== [7/$T] Pre-compilando as fases (a etapa mais demorada, 30-60 min) =="
    "$PY" psxrecomp/tools/compile_overlays.py \
        --captures aot-work/disc-records.json --game-toml game.toml \
        --recompiler build-recompiler/psxrecomp-game.exe \
        --runtime-include psxrecomp/runtime/include \
        --out-dir build-release/cache --compiler gcc --gcc "$CLANG" \
        --flavor 0 --jobs "$JOBS"
fi

echo
echo "Pronto! Execute: build-release/MetalSlugX_Recompiled.exe"
