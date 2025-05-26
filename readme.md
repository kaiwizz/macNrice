**sources:**
- [Nix is my favorite package manager to use on macOS](https://youtu.be/Z8BL8mdzWHI?si=ojwQbOVSoTEH29tR)
- [Stow has forever changed the way I manage my dotfiles](https://youtu.be/y6XCebnB9gs?si=JqBXY8RlmEXI4W_a)

- - -


```bash
cd ricing
stow .
```
This will make `symlinks` of all the files and folders at `~/`

To update the `nix` packages,
```bash
cd .nix/
nix flake update
sudo darwin-rebuild switch --flake ~/.nix#AirM3
```

To automatically update the `brew` packages, set the following flags in `flake.nix`

```nix
homebrew = {
	# ...
	onActivation = {
		cleanup = "zap";		# to remove apps not listed
		autoUpdate = true;	
		upgrade = true;			
	}; 
	# ...
};
```
