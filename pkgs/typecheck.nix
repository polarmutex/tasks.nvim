{
  pkgs,
  self,
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "haskell-tools-typecheck";

  src = self;

  phases = [
    "unpackPhase"
    "buildPhase"
    "checkPhase"
  ];

  doCheck = true;

  buildInputs = with pkgs; [
    sumneko-lua-language-server
  ];

  buildPhase = let
    luarc = pkgs.writeText ".luarc.json" ''
      {
        "$schema": "https://raw.githubusercontent.com/sumneko/vscode-lua/master/setting/schema.json",
        "Lua.diagnostics.globals": [
          "vim",
          "describe",
          "it",
          "assert"
        ],
        "Lua.diagnostics.libraryFiles": "Disable",
        "Lua.diagnostics.disable": [
          "duplicate-set-field",
        ],
        "Lua.workspace.library": [
          "${pkgs.neovim-unwrapped}/share/nvim/runtime/lua",
          "${pkgs.neovimPlugins.plenary-nvim}/lua"
        ],
        "Lua.runtime.version": "LuaJIT"
      }
    '';
  in ''
    mkdir -p $out
    cp -r lua $out/lua
    cp -r tests $out/tests
    cp .luacheckrc $out
    cp ${luarc} $out/.luarc.json
  '';
  checkPhase = ''
    export HOME=$(realpath .)
    cd $out
    lua-language-server --check "$out/lua" \
      --configpath "$out/.luarc.json" \
      --loglevel="trace" \
      --logpath "$out" \
      --checklevel="Warning"
    if [[ -f $out/check.json ]]; then
      echo "+++++++++++++++ lua-language-server diagnostics +++++++++++++++"
      cat $out/check.json
      exit 1
    fi
  '';
}
