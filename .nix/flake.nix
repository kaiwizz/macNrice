{
  	# To implement the changes
  	#> sudo darwin-rebuild switch --flake ~/.nix#AirM3
	# this is only for me as my folder is at "~/.nix"

  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
	nix-homebrew.url = "github:zhaofengli/nix-homebrew";

  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew}:
  let

    configuration = { pkgs, config, ... }: {

    nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
	
      environment.systemPackages =
      [ 
		pkgs.neofetch
	  	pkgs.mkalias	# to bring the apps in spotlight
		pkgs.stow
		pkgs.vim
		pkgs.git
		pkgs.gh
	  	pkgs.neovim
	    pkgs.alacritty
	    pkgs.tmux
	  	pkgs.texliveFull
		# pkgs.obsidian
      ]; 

	# setting myself as the primary user to use homebrew
	system.primaryUser = "kaiwizardly";

	homebrew = {
		enable = true;
		casks = [
			"firefox"
			"the-unarchiver"
		];
	};

	system.activationScripts.applications.text = let
	  env = pkgs.buildEnv {
	    name = "system-applications";
	    paths = config.environment.systemPackages;
	    pathsToLink = "/Applications";
	  };
	in
	  pkgs.lib.mkForce ''
	  # Set up applications.
	  echo "setting up /Applications..." >&2
	  rm -rf /Applications/Nix\ Apps
	  mkdir -p /Applications/Nix\ Apps
	  find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
	  while read -r src; do
	    app_name=$(basename "$src")
	    echo "copying $src" >&2
	    ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
	  done
	      '';

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
	darwinConfigurations."AirM3" = nix-darwin.lib.darwinSystem {
   	modules = [
		configuration 
		nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "kaiwizardly";

          };
        }
      ];
    };

	# Expose the package set, including overlays, for convenience.
	darwinPackages = self.darwinConfigurations."AirM3".pkgs;
  };
}
