# Awesome Multi Host

This is a small lua module for the Awesome Window Manager. It provides
multi-host capabilities such as


- spawning arbitrary programs on multiple hosts;
- starting [synergy][] on multiple hosts given all possible host combinations;
  ![Synergy menu](/misc/synergy.gif)
- starting [mpv][] on a remote host;

## Contributions

All contributions are welcome! I'm sure there are multiple ideas of programs
that could fit in.

## Dependencies

- [penlight][]
- **openssh-client, openssh-server**: commands are started on hosts through the SSH
  protocol. It's assumed that you have your SSH keys setup on each hosts you
  aim to use with amh.
- **avahi-utils**: hosts IPv4 ip addresses are dynamically resolved using avahi
  tools such as `avahi-resolve-host-name`.

[synergy]: https://symless.com/synergy
[mpv]: https://mpv.io/
[penlight]: https://github.com/stevedonovan/Penlight

## Author

Simon Désaulniers (sim.desaulniers@gmail.com)

