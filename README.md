# Awesome Multi Host

This is a small lua module for the Awesome Window Manager. It provides
multi-host capabilities such as


- spawning arbitrary programs on multiple hosts;
- starting [synergy][] on multiple hosts given all possible host combinations;

    ![Synergy menu](/misc/synergy.gif)
- starting [mpv][] on a remote host (passing the URL from the clipboard for
  e.g.).

    ![Mpv menu](/misc/mpv.gif)

See the wiki for concrete usage examples.

[synergy]: https://symless.com/synergy
[mpv]: https://mpv.io/

## Contributions

All contributions are welcome! I'm sure there are multiple ideas of programs
that could fit in.

## Dependencies

- [lua-socket][];
- [penlight][];
- **openssh-client, openssh-server**: commands are started on hosts through the SSH
  protocol. It's assumed that you have your SSH keys setup on each hosts you
  aim to use with amh.
- **avahi-utils**: hosts IPv4 ip addresses are dynamically resolved using avahi
  tools such as `avahi-resolve-host-name`.
- [lain][lain]: provides many useful functionalities and is most likely to be used
  by Awesome users. We use it for its menu iterator functionality which enables
  the user to iterate over choices interactively.

[lain]: https://github.com/lcpz/lain/
[lua-socket]: http://w3.impa.br/~diego/software/luasocket/
[penlight]: https://github.com/stevedonovan/Penlight

## Author

Simon Désaulniers (sim.desaulniers@gmail.com)

