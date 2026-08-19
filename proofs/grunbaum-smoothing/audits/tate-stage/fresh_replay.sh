#!/bin/bash
set -euo pipefail

ORIGINAL=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE=${TATE_SOURCE_PACKET:-/Users/daniel/github/grunbaum-smoothing-referee}
PROJECT=${TATE_SR_PROJECT:-/Users/daniel/github/sr-project}
RUN_ROOT=$(/usr/bin/mktemp -d /private/tmp/tate-stage-replay.XXXXXX)
COPY=$RUN_ROOT/audit
LOG=$RUN_ROOT/replay.log

# These successful reads prove that each denial probe names an existing file.
/usr/bin/head -c 1 "$ORIGINAL/code/prepare_inputs.py" >/dev/null
/usr/bin/head -c 1 "$SOURCE/MANIFEST.sha256" >/dev/null
/usr/bin/head -c 1 "$PROJECT/restructure_plan.md" >/dev/null

/usr/bin/ditto --norsrc --noextattr --noqtn --noacl "$ORIGINAL" "$COPY"
/bin/mkdir -p "$RUN_ROOT/home" "$RUN_ROOT/tmp"

if (
  cd "$COPY"
  /usr/bin/sandbox-exec -f "$COPY/code/fresh_replay.sb" \
    -D FRESH="$RUN_ROOT" \
    -D ORIGINAL="$ORIGINAL" \
    -D SOURCE="$SOURCE" \
    -D PROJECT="$PROJECT" \
    /usr/bin/env -i \
      HOME="$RUN_ROOT/home" \
      TMPDIR="$RUN_ROOT/tmp" \
      PATH=/usr/local/Cellar/python@3.13/3.13.7/bin:/Applications/Macaulay2-1.20/bin:/usr/local/Cellar/singular/4.4.1p3/bin:/usr/bin:/bin \
      LC_ALL=C LANG=C TZ=UTC TERM=dumb \
      PYTHONHASHSEED=0 PYTHONNOUSERSITE=1 PYTHONDONTWRITEBYTECODE=1 \
      OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1 \
      ORIGINAL="$ORIGINAL" SOURCE="$SOURCE" PROJECT="$PROJECT" \
      /bin/bash -c '
        set -euo pipefail
        if /usr/bin/head -c 1 "$ORIGINAL/code/prepare_inputs.py" >/dev/null 2>&1; then
          echo SANDBOX_ORIGINAL_AUDIT_READ_LEAK >&2; exit 90
        fi
        echo SANDBOX_ORIGINAL_AUDIT_READ_DENIED
        if /usr/bin/head -c 1 "$SOURCE/MANIFEST.sha256" >/dev/null 2>&1; then
          echo SANDBOX_SOURCE_PACKET_READ_LEAK >&2; exit 91
        fi
        echo SANDBOX_SOURCE_PACKET_READ_DENIED
        if /usr/bin/head -c 1 "$PROJECT/restructure_plan.md" >/dev/null 2>&1; then
          echo SANDBOX_SR_PROJECT_READ_LEAK >&2; exit 92
        fi
        echo SANDBOX_SR_PROJECT_READ_DENIED
        exec /bin/bash ./verify.sh
      '
) >"$LOG" 2>&1; then
  status=0
else
  status=$?
fi

/bin/cat "$LOG"
if [ "$status" -ne 0 ]; then
  echo "Fresh-copy replay failed with status $status; retained at $RUN_ROOT" >&2
  exit "$status"
fi
/usr/bin/grep -Fqx SANDBOX_ORIGINAL_AUDIT_READ_DENIED "$LOG"
/usr/bin/grep -Fqx SANDBOX_SOURCE_PACKET_READ_DENIED "$LOG"
/usr/bin/grep -Fqx SANDBOX_SR_PROJECT_READ_DENIED "$LOG"
/usr/bin/grep -Fqx TATE_STAGE_AUDIT_REPLAY_CERTIFIED "$LOG"
echo "FRESH_COPY_REPLAY_CERTIFIED"
echo "temporary_copy=$COPY"
echo "log=$LOG"
