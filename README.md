# ascii art
_repository of ascii art_

greetz to jewbird for creating [asciibird](https://github.com/birdneststream/asciibird), one of
the only ascii editors that supports 99-color mirc format.

## how to pump
**pumping with weechat**:
```
/set irc.server.efnet.anti_flood_prio_low 0
/set irc.server.efnet.anti_flood_prio_high 0

/alias pump /exec -o -sh while IFS= read -r l\; do printf "%s\n" "$l"\; sleep 0.3\; done < $1

/pump ~/art/tarot-tower.txt
```

**pumping on android with HexDroid**:

currently i see no local file system reads from hexdroid scripts, only http, so for now you're
limited to pumping from http sources, but you can use the following `.hex` script:
```
; pump.hex - /pump <url> pumps and ascii file fetched over http to the current channel,
; one line at a time, with a delay between lines. /pumpstop cancels.

on LOAD {
  set %pl_delay 400        ; ms between lines (timer minimum is 20)
  set %pl_busy false
}

alias pump {
  if ($len($1) == 0) { echo $chan usage: /pump <url> | return }
  if (%pl_busy == true) { echo $chan *** a pump is already running, /pumpstop to cancel | return }
  set %pl_busy true
  set %pl_chan $chan       ; stored globally so the timer ticks know where to send
  http.get $1 pl_fetched $chan
}

alias pumpstop {
  set %pl_busy false
  set %pl_lines $list()
  echo $chan *** pump cancelled
}

on SIGNAL:pl_fetched {
  if ($httpok != true) {
    echo $1 *** fetch failed ($httpstatus) $httperror
    set %pl_busy false
    return
  }
  ; normalise CRLF/LF to a sentinel, then split on it
  set -l %body $re_replace($httpbody, "\r?\n", "@@NL@@")
  set %pl_lines $split(%body, "@@NL@@")
  set %pl_idx 0
  timer %pl_delay pl_tick
}

on SIGNAL:pl_tick {
  if (%pl_busy != true) { return }
  if (%pl_idx >= $len(%pl_lines)) { set %pl_busy false | return }
  set -l %line $get(%pl_lines, %pl_idx)
  inc %pl_idx
  if ($len($trim(%line)) > 0) { msg %pl_chan %line }   ; IRC can't send empty lines
  timer %pl_delay pl_tick
}
```

## gallery

<!-- GALLERY:START -->

### agatha

<table>
<tr>
<td align="center"><a href="agatha/hello.txt"><img src=".img/agatha/hello_thumb.png" alt="Hello"></a><br><b>Hello</b></td>
<td align="center"><a href="agatha/tarot-hermit.txt"><img src=".img/agatha/tarot-hermit_thumb.png" alt="Tarot Hermit"></a><br><b>Tarot Hermit</b></td>
<td align="center"><a href="agatha/tarot-nineswords.txt"><img src=".img/agatha/tarot-nineswords_thumb.png" alt="Tarot Nineswords"></a><br><b>Tarot Nineswords</b></td>
</tr>
<tr>
<td align="center"><a href="agatha/tarot-tower.txt"><img src=".img/agatha/tarot-tower_thumb.png" alt="Tarot Tower"></a><br><b>Tarot Tower</b></td>
<td align="center"><a href="agatha/wtc25.txt"><img src=".img/agatha/wtc25_thumb.png" alt="Wtc25"></a><br><b>Wtc25</b></td>
</tr>
</table>

### psyk0

<table>
<tr>
<td align="center"><a href="psyk0/pissflection.txt"><img src=".img/psyk0/pissflection_thumb.png" alt="Pissflection"></a><br><b>Pissflection</b></td>
</tr>
</table>

<!-- GALLERY:END -->
