# Package Inventory

`pacman.txt` contains the public workstation's explicitly selected repository
packages. `aur.txt` contains AUR package names. The installer resolves current
compatible versions and dependencies rather than pinning an Arch snapshot.

`paru-git` is kept in `aur.txt` and bootstrapped directly from its current AUR
PKGBUILD. Existing installations are rebuilt so new upstream VCS revisions are
not skipped when AUR metadata has not changed. `makepkg` is not a standalone
Arch package: it is provided by `pacman`, which is part of the `base-devel`
dependency set. The installer's
full `pacman -Syu` upgrades `pacman` and therefore `makepkg` before Paru is
built.
