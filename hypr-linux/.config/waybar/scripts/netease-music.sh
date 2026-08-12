#!/bin/bash

########################################

PLAYERNAME="musicfox"
PLAYERSHELL="playerctl --player=$PLAYERNAME"

########################################

check_valid_player() {
  [[ "$($PLAYERSHELL status 2>&1)" != "Stopped" && "$($PLAYERSHELL status 2>&1)" != "No"* ]]
}

get_status() {
  [[ "$($PLAYERSHELL status)" == "Playing" ]]
}

get_status_icon() {
  if get_status; then
    echo "♫ ♪ ♫ ♪ ♥  "
    return
  fi

  echo "_ z Z Z ♥  "
}

get_title() {
  check_valid_player || return 1

  $PLAYERSHELL metadata title || echo ""
}

get_process() {
  check_valid_player || return 1

  position="$($PLAYERSHELL metadata --format '{{ duration(position) }}')"
  duration="$($PLAYERSHELL metadata --format '{{ duration(mpris:length) }}')"

  if [ -n $position ]; then
    echo "$position|$duration"
  else
    echo "$duration"
  fi
}

get_id () {
  check_valid_player || return 1

  $PLAYERSHELL metadata mpris:trackid | rev | cut -d "/" -f1 | sed "s/'//g"
}


get_lrc() {
  check_valid_player || return 1

  position="$($PLAYERSHELL metadata --format '{{ duration(position) }}')"

  lyc="$(
    $PLAYERSHELL metadata xesam:asText |
    awk -v pos="$position" '
      BEGIN {
        split(pos, p, ":")
        pos_sec = p[1] * 60 + p[2]
      }

      match($0, /^\[([0-9]+):([0-9]+(\.[0-9]+)?)\]/, t) {
        timestamp = t[1] * 60 + t[2]

        if (timestamp <= pos_sec) {
          lyric = $0
          sub(/^\[[^]]*\]/, "", lyric)
          current = lyric
        } else {
          exit
        }
      }

      END {
        if (current != "")
          print current
      }
    '
  )"

  echo $lyc
}

case "$1" in
  "id")
    get_id
    ;;
	"icons")
		get_status_icon
		;;
  "title")
    get_title
    ;;
  "process")
    get_process
    ;;
  "lyc")
    get_lrc
    ;;
	*)
		exit 1
		;;
esac
