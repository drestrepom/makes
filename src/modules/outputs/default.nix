{ head
, packages
}:
{ config
, lib
, ...
}:
let args = {
  builtinLambdas = import ../../args/builtin/lambdas.nix args;
  builtinShellCommands = ../../args/builtin/shell-commands.sh;
  builtinShellOptions = ../../args/builtin/shell-options.sh;
  config = config;
  inputs = config.inputs;
  outputs = config.outputs;
  lib = lib;
  path = path: head + path;
  makeDerivation = import ../../args/make-derivation args;
  makeEntrypoint = import ../../args/make-entrypoint args;
  makeSearchPaths = import ../../args/make-search-paths args;
  makeTemplate = import ../../args/make-template args;
};
in
{
  imports = [
    (import ./builtins args)
    (import ./custom.nix args)
  ];
  options = {
    attrs = lib.mkOption {
      type = lib.types.package;
    };
    outputs = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
    };
  };
  config = {
    attrs = config.inputs.makesPackages.nixpkgs.stdenv.mkDerivation {
      envList = builtins.toJSON (builtins.attrNames config.outputs);
      builder = builtins.toFile "builder" ''
        echo "$envList" > "$out"
      '';
      name = "makes-outputs-list";
    };
  };
}
