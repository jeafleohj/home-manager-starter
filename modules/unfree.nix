{
  pkgs,
  ...
}:

{
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "discord"
        "mongodb-compass"
        "vscode"
      ];
  };

  programs.vscode.enable = true;

  home.packages =
    with pkgs;
    [
    ]
    ++ pkgs.lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
      # Just x86_64
      discord
      mongodb-compass
    ];
}
