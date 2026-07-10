# Dotfiles

Personal dotfiles for my machines, more so a backup for me and a base for people who want to do the same.

**Instalation**

Clone the repository and copy/move the files to your home directory.

```bash
git clone -b nix https://github.com/jobucaldas/dotfiles.git
cd dotfiles
sudo nix-rebuild switch --flake ./flake#host
```

