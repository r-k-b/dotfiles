#!/usr/bin/env nu

def main [filename: string] {
  with-env { NIX_CONFIG: "substituters = https://cache.nixos.org" } {
    nix shell "nixpkgs#ffmpeg" --command ffmpeg -i $"/home/rkb/Videos/($filename).mkv" -af "pan=mono| c0=FL" -c:v copy $"/home/rkb/Videos/($filename).mono.mkv"
  }
}
