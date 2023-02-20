{listOptional, ...}: {
  config,
  lib,
  ...
}: {
  options = {
    cache = {
      extra = lib.mkOption {
        default = {};
        type = lib.types.attrsOf (lib.types.submodule (_: {
          options = {
            enable = lib.mkOption {
              default = false;
              type = lib.types.bool;
            };
            priority = lib.mkOption {
              type = lib.types.ints.positive;
            };
            pubKey = lib.mkOption {
              default = "";
              type = lib.types.str;
            };
            token = lib.mkOption {
              type = lib.types.str;
              default = "";
            };
            type = lib.mkOption {
              type = lib.types.enum ["cachix" "attic"];
            };
            url = lib.mkOption {
              type = lib.types.str;
            };
            write = lib.mkOption {
              default = false;
              type = lib.types.bool;
            };
          };
        }));
      };
      readNixos = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
    };
  };
  config = {
    config = {
      cache = builtins.concatLists [
        (listOptional config.cache.readNixos {
          url = "https://cache.nixos.org";
          pubKey = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
          type = "other";
        })
        (listOptional config.cache.readAndWrite.enable {
          name = config.cache.readAndWrite.name;
          url = "https://${config.cache.readAndWrite.name}.cachix.org/";
          pubKey = config.cache.readAndWrite.pubKey;
          type = "cachix";
        })
        (builtins.map
          (cache: {
            inherit (cache) url;
            inherit (cache) pubKey;
            type = "other";
          })
          config.cache.readExtra)
      ];
    };
  };
}
