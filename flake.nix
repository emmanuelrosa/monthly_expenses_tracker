{
  description = "A Nix flake for Monthly Expenses Tracker";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      monthly-expenses-tracker = pkgs.callPackage ./pkgs/monthly-expenses-tracker {}; 

      monthly-expenses-tracker-web = pkgs.callPackage ./pkgs/monthly-expenses-tracker {
          targetFlutterPlatform = "web";
       }; 

      default = self.packages."${system}".monthly-expenses-tracker;
    };
  };
}
