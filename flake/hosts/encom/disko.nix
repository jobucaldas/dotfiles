# Existing layout; do not run Disko format or destroy modes on this disk
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00BL7_S64KNF0W653632";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          name = "EFI";
          label = "EFI";
          uuid = "ef8c909b-3c90-4d1d-af50-5834a211e430";
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
          uuid = "6a9d18a6-aa00-4f7f-a511-3d749ebfd191";
          start = "2101248s";
          end = "1000215143s";
          type = "8300";
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
}
