{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-darwin"];
    buildEachSystem = output: map output systems;
    buildAllSystems = output: (
      builtins.foldl' nixpkgs.lib.recursiveUpdate {} (buildEachSystem output)
    );
  in
    buildAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      packages.${system} = {
        topiary-nushell = pkgs.callPackage ./package.nix {
          tree-sitter-nu = fetchGit {
            url = "https://github.com/nushell/tree-sitter-nu";
            rev = "4f577aaa735154f934594b598a69ed7b1b707cf6";
          };
        };
        default = self.packages.${system}.topiary-nushell;
      };
      apps.${system} = {
        topiary-nushell = {
          type = "app";
          program = "${pkgs.lib.getExe self.packages.${system}.topiary-nushell}";
          meta = {
            description = "Topiary with NuShell support";
          };
        };
        default = self.apps.${system}.topiary-nushell;
      };
    });
}
