**source:**[Nix is my favorite package manager to use on macOS](https://youtu.be/Z8BL8mdzWHI?si=ojwQbOVSoTEH29tR)
- - -


```bash
cd ricing
stow .
```
This will make `symlinks` of all the files and folders at `~/`

to update the packages,
```bash
cd .nix/
nix flake update
sudo darwin-rebuild switch --flake ~/.nix#AirM3
```


