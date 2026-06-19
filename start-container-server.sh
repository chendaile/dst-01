#!/bin/bash

# Nothing game-related is baked into the image; it is all fetched fresh with steamcmd into the
# persisted ./volumes/server_dst mount on every boot:
#   - the game itself (app 343050), always the current version;
#   - each server mod listed in DSTWhalesCluster/mods/server_mods.txt, downloaded with steamcmd
#     and installed as a LOCAL mod (server_dst/mods/workshop-<id>/).
# We fetch mods with steamcmd instead of the in-game Workshop auto-download because that
# downloader has a short, non-configurable timeout baked into the engine that keeps failing on
# this network (EResult 16). Local mods load with no timeout.

DST_DIR="$HOME/server_dst"
DST_BIN="$DST_DIR/bin/dontstarve_dedicated_server_nullrenderer"
CLUSTER_DIR="$HOME/.klei/DoNotStarveTogether/DSTWhalesCluster"
MODS_FILE="$CLUSTER_DIR/mods/server_mods.txt"
WORKSHOP_APP=322330   # DST client app id (Workshop items live under this app)

# Read the workshop ids to install: one numeric id per line in server_mods.txt ('#' comments ok).
MOD_IDS=""
if [ -f "$MODS_FILE" ]; then
  MOD_IDS=$(sed 's/#.*//' "$MODS_FILE" | awk '{print $1}' | grep -E '^[0-9]+$')
fi

# One steamcmd run: update the game, then download every listed mod.
# - force_install_dir must come before login, or steamcmd ignores it.
# - No @ShutdownOnFailedCommand, so one failed mod download does not abort the rest.
steam_args=( +@NoPromptForPassword 1
             +force_install_dir "$DST_DIR"
             +login anonymous
             +app_update 343050 validate )
for id in $MOD_IDS; do
  steam_args+=( +workshop_download_item "$WORKSHOP_APP" "$id" )
done
steam_args+=( +quit )

/home/dst/steamcmd.sh "${steam_args[@]}"

# Fail loudly if the game itself did not install, instead of a confusing exit 127 later.
if [ ! -x "$DST_BIN" ]; then
  echo "=================================================================="
  echo "[start] ERROR: DST server binary missing after steamcmd update."
  echo "[start]   1) is proxy/TUN up so steamcmd can reach Steam?  AND"
  echo "[start]   2) is ./volumes/server_dst writable by uid 1000?"
  echo "[start]      (on host:  sudo chown -R 1000:1000 ./volumes/server_dst )"
  echo "=================================================================="
  exit 1
fi

# Install each downloaded mod as a LOCAL mod: server_dst/mods/workshop-<id>/
for id in $MOD_IDS; do
  src="$DST_DIR/steamapps/workshop/content/$WORKSHOP_APP/$id"
  dst="$DST_DIR/mods/workshop-$id"
  if [ -d "$src" ]; then
    rm -rf "$dst"
    cp -r "$src" "$dst"
    echo "[start] installed local mod workshop-$id"
  else
    echo "[start] WARNING: mod $id did not download (steamcmd failed?); it will not load."
  fi
done

# Refresh dedicated_server_mods_setup.lua (kept disabled) and push modoverrides.lua to both shards.
ds_mods_setup="$CLUSTER_DIR/mods/dedicated_server_mods_setup.lua"
if [ -f "$ds_mods_setup" ]; then
  cp "$ds_mods_setup" "$DST_DIR/mods/"
fi

modoverrides="$CLUSTER_DIR/mods/modoverrides.lua"
if [ -f "$modoverrides" ]; then
  cp "$modoverrides" "$CLUSTER_DIR/Master/"
  cp "$modoverrides" "$CLUSTER_DIR/Caves/"
fi

cd "$DST_DIR/bin" || exit 1
./dontstarve_dedicated_server_nullrenderer -cluster DSTWhalesCluster -shard "$SHARD_NAME"
