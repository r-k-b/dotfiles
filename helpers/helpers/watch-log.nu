#!/usr/bin/env nu

def main [ url: string, interval: duration = 4sec, lines: int = 30 ] {
  loop {
     let result = curl $url | lines | last $lines
     clear
     print $result
     sleep $interval
  }
}

