# Commented out, because I'm not using the resulting zfs stores.

# Create 3 GB ZFS pool for postgresq
# and 3 GB ZFS pool for other roots.

# /opt/lxc/disks:
#   file.directory:
#     - makedirs: True

# dd if=/dev/zero of=/opt/lxc/disks/pgdata.img bs=100M count=30:
#   cmd.run:
#     - creates: /opt/lxc/disks/pgdata.img

# pgdata.img:
#   zpool.present:
#     - config:
#         import: false
#         force: true
#     - properties:
#         comment: Pool for postgresql data
#     - layout:
#         - /opt/lxc/disks/pgdata.img

# dd if=/dev/zero of=/opt/lxc/disks/rootdisk.img bs=100M count=30:
#   cmd.run:
#     - creates: /opt/lxc/disks/root.img

# root.img:
#   zpool.present:
#     - config:
#         import: false
#         force: true
#     - properties:
#         comment: Pool for most lxc images
#     - layout:
#         - /opt/lxc/disks/rootdisk.img
