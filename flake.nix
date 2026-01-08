{
  description = "Minecraft server configuration module";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-minecraft,
  }: {
    nixosModules.default = {
      config,
      pkgs,
      ...
    }: {
      imports = [nix-minecraft.nixosModules.minecraft-servers];

      options.mcserver = {
        secrets = nixpkgs.lib.mkOption {
          type = nixpkgs.lib.types.attrs;
          description = "Secrets for minecraft server (seed, rcon password)";
        };
      };

      config = let
        secrets = config.mcserver.secrets;
      in {
        services.minecraft-servers = {
          enable = true;
          eula = true;
          openFirewall = true;
          servers.communityMCserver = {
            enable = true;
            package = nix-minecraft.legacyPackages.${pkgs.system}.fabricServers.fabric-1_20_1;
            jvmOpts = [
              "-Xms4G"
              "-Xmx4G"
              "-XX:+UseG1GC"
              "-XX:+ParallelRefProcEnabled"
              "-XX:MaxGCPauseMillis=200"
              "-XX:+UnlockExperimentalVMOptions"
              "-XX:+DisableExplicitGC"
              "-XX:+AlwaysPreTouch"
              "-XX:G1NewSizePercent=30"
              "-XX:G1MaxNewSizePercent=40"
              "-XX:G1HeapRegionSize=8M"
              "-XX:G1ReservePercent=20"
              "-XX:G1HeapWastePercent=5"
              "-XX:G1MixedGCCountTarget=4"
              "-XX:InitiatingHeapOccupancyPercent=15"
              "-XX:G1MixedGCLiveThresholdPercent=90"
              "-XX:G1RSetUpdatingPauseTimePercent=5"
              "-XX:SurvivorRatio=32"
              "-XX:+PerfDisableSharedMem"
              "-XX:MaxTenuringThreshold=1"
            ];
            serverProperties = {
              server-port = 25565;
              gamemode = 0;
              spawn-chunk-radius = 0;
              difficulty = 3;
              white-list = true;
              level-seed = secrets.minecraft-seed;
              max-players = 100;
              spawn-protection = 0;
              view-distance = 6;
              enable-rcon = true;
              enforce-whitelist = true;
              "rcon.password" = builtins.readFile secrets.RCON_Password;
              "rcon.port" = 16260;
            };
            symlinks = {
              "mods" = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {});
              "ops.json" = pkgs.writeText "ops.json" (builtins.toJSON [
                {
                  uuid = "080aa9de-bcf6-4f3d-8e5d-a86f4977885a";
                  name = "hexolexo";
                  level = 4;
                  bypassesPlayerLimit = false;
                }
              ]);
            };
          };
        };

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [25565 51820];
          interfaces.wg0.allowedTCPPorts = [16260];
        };
      };
    };
  };
}
