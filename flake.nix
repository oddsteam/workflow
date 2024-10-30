{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }: 
  let 
    supportedSystems = [ "aarch64-darwin" ]; 
  in 
  {
    devShells = builtins.foldl' (prev: system: prev // {
      ${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          ruby_3_3
          imagemagick
          # playwright
          # playwright-driver
        ];

        # shellHook = ''
        #   export PLAYWRIGHT_BROWSERS_PATH=${nixpkgs.legacyPackages.${system}.playwright-driver.browsers}
        #   export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
        # '';
      };
    }) {} supportedSystems;

    packages = builtins.foldl' (prev: system: prev // {
      ${system}.default = nixpkgs.legacyPackages."${system}".hello; 
    }) {} supportedSystems;
  };
}