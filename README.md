# Forgotten Wonderland SMP server flake

## Usage
```nix
{
  inputs.minecraft-server.url = "github:hexolexo/The_Wonderland_SMP";

  outputs = {
    self,
    nixpkgs,
    minecraft-server,
    ...
  }: {
    nixosConfigurations.{HOSTNAME} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        minecraft-server.nixosModules.default
        {
          mcserver.secrets = {
            minecraft-seed = "your-seed";
            RCON_Password = "your-password";
          };
        }
      ];
    };
  };
}
```
