{ config, pkgs, ... }:

{
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
    anki
    ark
    hexchat
    filelight
    fira-code
    flameshot
    gwenview
    iosevka
    jetbrains.datagrip
    jetbrains.idea-ultimate
    jetbrains-mono
    jetbrains.rider
    jetbrains.webstorm
    jq
    kdeApplications.okular
    libreoffice
    openconnect

    # Can pavucontrol bring back the system sounds?
    # https://www.reddit.com/r/kde/comments/6838fr/system_sounds_keep_breaking/
    pavucontrol

    redshift
    remmina
    simplescreenrecorder
    spotify
    steam-run
    tldr
    vlc
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
