{ __nixpkgs__
, __toModuleOutputs__
, makeDerivation
, makeDerivationParallel
, makePythonPypiEnvironment
, makePythonVersion
, projectPath
, projectPathLsDirs
, ...
}:
{ config
, lib
, ...
}:
let
  makeModule = name: { extraSources, python, src }: {
    name = "/lintPython/module/${name}";
    value = makeDerivation {
      env = {
        envSettingsMypy = ./settings-mypy.cfg;
        envSettingsProspector = ./settings-prospector.yaml;
        envSrc = projectPath src;
      };
      name = "lint-python-module-for-${name}";
      searchPaths = {
        bin = [
          __nixpkgs__.findutils
        ];
        source = extraSources ++ [
          (makePythonPypiEnvironment {
            dependencies = {
              "mypy" = "0.910";
              "prospector" = "1.3.1";
            };
            name = "lint-python";
            python = makePythonVersion python;
            subDependencies = {
              "astroid" = "2.4.1";
              "colorama" = "0.4.4";
              "dodgy" = "0.2.1";
              "flake8" = "3.8.4";
              "flake8-polyfill" = "1.0.2";
              "isort" = "4.3.21";
              "lazy-object-proxy" = "1.4.3";
              "mccabe" = "0.6.1";
              "mypy-extensions" = "0.4.3";
              "pep8-naming" = "0.10.0";
              "pycodestyle" = "2.6.0";
              "pydocstyle" = "6.1.1";
              "pyflakes" = "2.2.0";
              "pylint" = "2.5.3";
              "pylint-celery" = "0.3";
              "pylint-django" = "2.1.0";
              "pylint-flask" = "0.6";
              "pylint-plugin-utils" = "0.6";
              "pyyaml" = "5.4.1";
              "requirements-detector" = "0.7";
              "setoptconf" = "0.2.0";
              "six" = "1.16.0";
              "snowballstemmer" = "2.1.0";
              "toml" = "0.10.2";
              "typing-extensions" = "3.10.0.0";
              "wrapt" = "1.12.1";
            };
            sha256 = "0nlgpbszrmg1z7v6rhfqdjkrmv4diy3z9q3hn70z591m4pz93d4x";
          })
        ];
      };
      builder = ./builder.sh;
    };
  };
  makeDirOfModules = name: { extraSources, python, src }:
    let
      modules = builtins.map
        (moduleName: {
          name = "/lintPython/dirOfModules/${name}/${moduleName}";
          value = (makeModule moduleName {
            inherit extraSources;
            inherit python;
            src = "${src}/${moduleName}";
          }).value;
        })
        (projectPathLsDirs src);
    in
    (modules ++ [{
      name = "/lintPython/dirOfModules/${name}";
      value = makeDerivationParallel {
        dependencies = lib.attrsets.catAttrs "value" modules;
        name = "lint-python-dir-of-modules-for-${name}";
      };
    }]);
in
{
  options = {
    lintPython = {
      dirsOfModules = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.submodule (_: {
          options = {
            extraSources = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.package;
            };
            python = lib.mkOption {
              type = lib.types.enum [ "3.7" "3.8" "3.9" ];
            };
            src = lib.mkOption {
              type = lib.types.str;
            };
          };
        }));
      };
      modules = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.submodule (_: {
          options = {
            extraSources = lib.mkOption {
              default = [ ];
              type = lib.types.listOf lib.types.package;
            };
            python = lib.mkOption {
              type = lib.types.enum [ "3.7" "3.8" "3.9" ];
            };
            src = lib.mkOption {
              type = lib.types.str;
            };
          };
        }));
      };
    };
  };
  config = {
    outputs =
      (__toModuleOutputs__ makeModule config.lintPython.modules) //
      (__toModuleOutputs__ makeDirOfModules config.lintPython.dirsOfModules);
  };
}
