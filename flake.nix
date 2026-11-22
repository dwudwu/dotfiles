{
  description = "dotfiles";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # The headless layer: key-only SSH, automatic sign-in, never sleep,
    # Tailscale. Only its module is used, so it follows our nixpkgs and
    # nix-darwin instead of pulling its own.
    headless.url = "github:kunchenguid/headless";
    headless.inputs.nixpkgs.follows = "nixpkgs";
    headless.inputs.nix-darwin.follows = "nix-darwin";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, headless, nixpkgs }:
    let
      # The one username line to change if this isn't your machine.
      # bootstrap.sh offers to rewrite this for you if your macOS username differs.
      user = "studio";
    in
    {
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          headless.darwinModules.headless
          ./headless.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
      # The headless skill's scripts build `darwinConfigurations.machine`;
      # it is the same system under the name they expect.
      darwinConfigurations.machine = self.darwinConfigurations."mac";
    };
}
