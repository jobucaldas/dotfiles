# Existing layout; do not run Disko format or destroy modes on these disks
{
  disko.devices.disk = {
    main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SSSTC_CL1-4D256_SS1C86490L2BR1BJ56FS";

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "EFI";
            label = "EFI";
            uuid = "868cb949-fdeb-43e2-acce-06bddee6f7ef";
            start = "4096s";
            end = "2101247s";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            priority = 1000;
            name = "root";
            label = "root";
            uuid = "1a25e136-0165-49ce-b128-96f38916324a";
            start = "2101248s";
            end = "500118119s";
            type = "8300";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.crypttabExtraOpts = [
                "tpm2-device=auto"
                "tpm2-pcrs=7"
              ];
              content = {
                type = "btrfs";
                mountpoint = "/";
                mountOptions = [ "subvolid=5" ];
                subvolumes = {
                  "/home".mountpoint = "/home";
                  "/nix".mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };

    sandssd = {
      type = "disk";
      device = "/dev/disk/by-id/ata-SanDisk_SSD_PLUS_1000GB_24154H800699";

      content = {
        type = "gpt";
        partitions.data = {
          priority = 1;
          name = "Sand SSD";
          label = "Sand SSD";
          uuid = "3ea94124-2b6a-4523-9328-cab369573240";
          start = "2048s";
          end = "1953523711s";
          type = "8300";
          content = {
            type = "luks";
            name = "cryptsandssd";
            settings.crypttabExtraOpts = [
              "tpm2-device=auto"
              "tpm2-pcrs=7"
            ];
            content = {
              type = "btrfs";
              mountpoint = "/mnt/sandssd";
            };
          };
        };
      };
    };

    sea1 = {
      type = "disk";
      device = "/dev/disk/by-id/ata-ST1000LM049-2GH172_WGS3AFLR";

      content = {
        type = "gpt";
        partitions.data = {
          priority = 1;
          name = "Sea 1";
          label = "Sea 1";
          start = "2048s";
          end = "1953523711s";
          type = "8300";
          content = {
            type = "luks";
            name = "cryptsea1";
            settings.crypttabExtraOpts = [
              "tpm2-device=auto"
              "tpm2-pcrs=7"
            ];
            content = {
              type = "btrfs";
              mountpoint = "/mnt/sea1";
            };
          };
        };
      };
    };
  };
}
