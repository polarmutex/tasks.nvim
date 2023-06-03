{
  description = "Tutorial Flake accompanying vimconf talk.";

  nixConfig = {
    extra-substituters = "https://polarmutex.cachix.org";
    extra-trusted-public-keys = "polarmutex.cachix.org-1:kUFH4ftZAlTrKlfFaKfdhKElKnvynBMOg77XRL2pc08=";
  };

  outputs = {
    self,
    nixpkgs,
    neovim-flake,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

      imports = [
        ./nix/checks.nix
      ];

      flake = {
        overlays.default = _final: _prev: {
        };
      };

      perSystem = {
        config,
        pkgs,
        inputs',
        self',
        system,
        ...
      }: let
        overlays = [
          (_final: _prev: {
            inherit (self'.packages) neovim-git;
            inherit (self'.packages) docgen;
          })
          self.overlays.default
          (_final: _prev: {
            neovimPlugins = {
              inherit (self'.packages) plenary-nvim;
              inherit (self'.packages) tasks-nvim;
              inherit (self'.packages) telescope-nvim;
            };
          })
        ];
      in {
        _module.args = {
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        };

        packages = let
          # from https://github.com/nix-community/neovim-nightly-overlay
          neovim-git = inputs'.neovim-flake.packages.neovim.overrideAttrs (o: {
            patches = builtins.filter (p:
              (
                if builtins.typeOf p == "set"
                then baseNameOf p.name
                else baseNameOf
              )
              != "use-the-correct-replacement-args-for-gsub-directive.patch")
            o.patches;
          });
          plenary-nvim = let
            src = inputs.plenary-nvim;
          in
            pkgs.pkgs.vimUtils.buildVimPluginFrom2Nix {
              name = "plenary.nvim";
              inherit src;
              version = src.lastModifiedDate;
            };
          tasks-nvim = let
            src = self;
          in
            pkgs.pkgs.vimUtils.buildVimPluginFrom2Nix {
              name = "tasks.nvim";
              inherit src;
              version = src.lastModifiedDate;
            };
          telescope-nvim = let
            src = inputs.telescope-nvim;
          in
            pkgs.pkgs.vimUtils.buildVimPluginFrom2Nix {
              name = "telescope.nvim";
              inherit src;
              version = src.lastModifiedDate;
            };
        in {
          default = config.packages.tasks-nvim;
          docgen = pkgs.callPackage ./pkgs/docgen.nix {};
          inherit neovim-git;
          inherit plenary-nvim;
          inherit tasks-nvim;
          inherit telescope-nvim;
          typecheck = pkgs.callPackage ./pkgs/typecheck.nix {inherit (inputs) self;};
          plenary-test = pkgs.callPackage ./pkgs/plenary-test.nix {
            name = "tasks-nvim";
            inherit (inputs) self;
          };
        };

        devShells = {
          default = pkgs.mkShell {
            packages = builtins.attrValues {
              inherit (pkgs) lemmy-help;
            };
            inherit (self.checks.${system}.pre-commit-check) shellHook;
          };
        };
      };
    };

  # Input source for our derivation
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # inputs for tests
    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    telescope-nvim = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
  };
}
