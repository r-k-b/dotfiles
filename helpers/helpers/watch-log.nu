#!/usr/bin/env nu

def main [ url: string, interval: duration = 4sec, lines: int = 30 ] {
  loop {
     clear
     curl $url | lines | last $lines | print
     sleep $interval
  }
}

