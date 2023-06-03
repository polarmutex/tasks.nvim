{
  self,
  inputs,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    inputs',
    self',
    system,
    ...
  }: {
    # check to see if any config errors ars displayed
    # TODO need to have version with all the config
    checks = let
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = self;
        hooks = {
          alejandra.enable = true;
          stylua.enable = true;
          luacheck.enable = true;
        };
      };
    in {
      inherit pre-commit-check;
      inherit (config.packages) typecheck;
    };
  };
}
