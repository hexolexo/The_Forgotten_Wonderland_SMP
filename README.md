# Forgotten Wonderland SMP server flake

## Usage
```nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        minecraft-server.url = "github:hexolexo/The_Forgotten_Wonderland_SMP";
    };
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

networking.wireguard.interfaces = {
    wg0 = {
        ips = ["10.0.0.IP/24"];

        privateKeyFile = "/etc/wireguard/privkey"; # GENERATE WITH `wg genkey`

        peers = [
            {
                publicKey = ""; # GENERATE THIS WITH `echo "$PRIVATE" | wg pubkey`
                endpoint = "${secrets.HomeIP}:51820";

                allowedIPs = ["10.0.0.0/24"];
                persistentKeepalive = 25;
            }
        ];
    };
};

```
