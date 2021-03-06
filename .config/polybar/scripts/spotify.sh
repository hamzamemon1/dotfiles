#!/bin/sh
main() {
  if ! pgrep -x spotify >/dev/null; then
    echo " Start a track"; exit
  fi

  # TODO: look into exclamation mark bug
  cmd="org.freedesktop.DBus.Properties.Get"
  domain="org.mpris.MediaPlayer2"
  path="/org/mpris/MediaPlayer2"

  meta=$(dbus-send --print-reply --dest=${domain}.spotify \
    /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:${domain}.Player string:Metadata)

  artist=$(echo "$meta" | sed -nr '/xesam:artist"/,+2s/^ +string "(.*)"$/\1/p' | tail -1 | sed "s/\&/+/g")
  album=$(echo "$meta" | sed -nr '/xesam:album"/,+2s/^ +variant +string "(.*)"$/\1/p' | tail -1)

  title=$(echo "$meta" | sed -nr '/xesam:title"/,+2s/^ +variant +string "(.*)"$/\1/p' | tail -1 | sed "s/\&/+/g")
  if [ ${#title} -ge 30 ]; then
    title=$(echo "$title" | cut -c 1-30)
    title="${title}..."
  fi

  echo " ${*:-%artist% - %title%}" | sed "s/%artist%/$artist/g;s#%title%#$title#g;s/%album%/$album/g"i | sed 's/&/\\&/g'
}

main "$@"
