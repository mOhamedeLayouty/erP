#!/usr/bin/env bash
set -e

# Run from Git Bash on Windows
# Assumes you are inside: /c/erp/unified (or wherever you extracted this package)

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[1/5] Killing old Node processes on ports 8080 and 5173/5174 (best effort)"
# On Windows Git Bash, netstat+taskkill works
for P in 8080 5173 5174 5175; do
  PID=$(netstat -ano 2>/dev/null | grep ":$P" | grep LISTENING | awk '{print $5}' | head -n 1 || true)
  if [ -n "$PID" ]; then
    echo " - killing PID $PID (port $P)"
    taskkill //PID "$PID" //F >/dev/null 2>&1 || true
  fi
done

echo "[2/5] Backend env setup"
cd "$ROOT_DIR/backend"
if [ ! -f .env ]; then
  cp .env.example .env
  echo " - created backend/.env from .env.example"
fi

echo "[3/5] Installing backend deps + running backend (port 8080)"
npm i
npm run dev &
BACK_PID=$!

echo "[4/5] Frontend env setup"
cd "$ROOT_DIR/frontend"
if [ ! -f .env ]; then
  cp .env.example .env
  echo " - created frontend/.env from .env.example"
fi

echo "[5/5] Installing frontend deps + running frontend (Vite)"
npm i
npm run dev

# If you stop Vite, also stop backend
trap "kill $BACK_PID 2>/dev/null || true" EXIT
