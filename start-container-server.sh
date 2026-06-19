#!/bin/bash

# The DST game is NOT relied upon from the image. It is downloaded fresh into the persisted
# ./volumes/server_dst mount on every boot, so the server always runs the CURRENT version.
# (An out-of-date server does not appear in the in-game server browser.)

DST_DIR="$HOME/server_dst"
DST_BIN="$DST_DIR/bin/dontstarve_dedicated_server_nullrenderer"

# Install / update DST.
# NOTE: force_install_dir MUST come before login, otherwise steamcmd ignores it and prints
# "Please use force_install_dir before logon!".
/home/dst/steamcmd.sh \
  +@ShutdownOnFailedCommand 1 \
  +@NoPromptForPassword 1 \
  +force_install_dir "$DST_DIR" \
  +login anonymous \
  +app_update 343050 validate \
  +quit

# Stop here with a clear message if the download did not produce a runnable binary, instead of
# crashing later with a confusing "No such file or directory" / exit 127.
if [ ! -x "$DST_BIN" ]; then
  echo "=================================================================="
  echo "[start] ERROR: DST server binary missing after steamcmd update."
  echo "[start] steamcmd could not install the game. Check both:"
  echo "[start]   1) proxy/TUN is up so steamcmd can reach Steam, AND"
  echo "[start]   2) ./volumes/server_dst is writable by uid 1000"
  echo "[start]      (on host:  sudo chown -R 1000:1000 ./volumes/server_dst )"
  echo "=================================================================="
  exit 1
fi

# Copy dedicated_server_mods_setup.lua so the configured mods get downloaded
ds_mods_setup="$HOME/.klei/DoNotStarveTogether/DSTWhalesCluster/mods/dedicated_server_mods_setup.lua"
if [ -f "$ds_mods_setup" ]
then
  cp "$ds_mods_setup" "$DST_DIR/mods/"
fi

# Copy modoverrides.lua to both shards
modoverrides="$HOME/.klei/DoNotStarveTogether/DSTWhalesCluster/mods/modoverrides.lua"
if [ -f "$modoverrides" ]
then
  cp "$modoverrides" "$HOME/.klei/DoNotStarveTogether/DSTWhalesCluster/Master/"
  cp "$modoverrides" "$HOME/.klei/DoNotStarveTogether/DSTWhalesCluster/Caves/"
fi

cd "$DST_DIR/bin" || exit 1
./dontstarve_dedicated_server_nullrenderer -cluster DSTWhalesCluster -shard "$SHARD_NAME"
