{ config
, ...
}:
{
  deployContainerImage = {
    enable = true;
    images = {
      makesGitHub = {
        src = config.outputs."container-image";
        registry = "ghcr.io";
        tag = "fluidattacks/makes:main";
      };
      makesGitHubMonthly = {
        src = config.outputs."container-image";
        registry = "ghcr.io";
        tag = "fluidattacks/makes:21.08-pre1";
      };
      makesGitLab = {
        src = config.outputs."container-image";
        registry = "registry.gitlab.com";
        tag = "fluidattacks/product/makes:main";
      };
      makesGitLabMonthly = {
        src = config.outputs."container-image";
        registry = "registry.gitlab.com";
        tag = "fluidattacks/product/makes:21.08-pre1";
      };
    };
  };
  formatBash = {
    enable = true;
    targets = [ "/" ];
  };
  formatPython = {
    enable = true;
    targets = [ "/" ];
  };
  helloWorld = {
    enable = true;
    name = "Jane Doe";
  };
}
