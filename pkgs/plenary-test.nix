{
  pkgs,
  self,
  name,
  withTelescope ? true,
  withHls ? true,
  extraPkgs ? [],
}: let
  nvim-wrapped = pkgs.wrapNeovim pkgs.neovim-git {
    configure = {
      customRC = ''
        lua << EOF
        vim.cmd('runtime! plugin/plenary.vim')
        EOF
      '';
      packages.myVimPackage = {
        start =
          [
            pkgs.neovimPlugins.tasks-nvim
            pkgs.neovimPlugins.plenary-nvim
          ]
          ++ (
            if withTelescope
            then [pkgs.neovimPlugins.telescope-nvim]
            else []
          );
      };
    };
  };
in
  pkgs.stdenv.mkDerivation {
    inherit name;

    src = self;

    phases = [
      "unpackPhase"
      "buildPhase"
      "checkPhase"
    ];

    doCheck = true;

    buildInputs = with pkgs;
      [
        nvim-wrapped
        makeWrapper
        curl
      ]
      ++ (
        if withHls
        then [haskell-language-server]
        else []
      )
      ++ extraPkgs;

    buildPhase = ''
      mkdir -p $out
      cp -r tests $out
      # FIXME: Fore some reason, this doesn't work
      # haskell-language-server-wrapper generate-default-config > $out/tests/hls.json
    '';

    checkPhase = ''
      export HOME=$(realpath .)
      export TEST_CWD=$(realpath $out/tests)
      cd $out
      nvim --headless --noplugin -c "PlenaryBustedDirectory tests {nvim_cmd = 'nvim'}"
    '';
  }
