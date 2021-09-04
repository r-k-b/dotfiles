{ config, pkgs, ... }:
let
  idea_2021_1 = (import (builtins.fetchTarball {
    name = "elm-plugin-downgrade";
    url =
      "https://github.com/NixOS/nixpkgs/archive/860b56be91fb874d48e23a950815969a7b832fbc.tar.gz";
    sha256 = "07i03028w3iak0brdnkp79ci8vqqbrgr5p5i9sk87fhbg3656xhw";
  }) { }).jetbrains.idea-ultimate;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "rkb";
  home.homeDirectory = "/home/rkb";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  home.packages = with pkgs; [
    ag
    akregator
    anki
    ark
    autossh
    bat # for previews in fzf
    calibre
    dropbox
    entr
    evince
    hexchat
    filelight
    fira-code
    flameshot
    fzf
    gwenview
    iosevka
    jetbrains.datagrip

    # Elm plugin doesn't support 2021.2 yet
    # https://github.com/klazuka/intellij-elm/issues/763
    # https://github.com/klazuka/intellij-elm/pull/764
    #jetbrains.idea-ultimate
    idea_2021_1

    jetbrains-mono
    jetbrains.pycharm-professional
    jetbrains.rider
    jetbrains.webstorm
    jq
    libreoffice
    msgviewer # for outlook .msg files
    notepadqq
    okular
    openconnect

    # Can pavucontrol bring back the system sounds?
    # https://www.reddit.com/r/kde/comments/6838fr/system_sounds_keep_breaking/
    pavucontrol

    postman
    redshift
    remmina
    scc # for quick line counts by language
    simplescreenrecorder
    slack
    spotify
    steam-run
    teams # for PHD
    tldr
    unclutter-xfixes
    vlc
    zoom-us
    vscode
    workrave
    xsel
  ];

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-better-whitespace
      vim-nix
      editorconfig-vim
    ];
    settings = { };
    extraConfig = ''
      set viminfo+=n~/.viminfo
      set list
      set listchars=tab:>-
      set relativenumber
    '';
  };
}
