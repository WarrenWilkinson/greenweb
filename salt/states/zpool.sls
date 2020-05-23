# Create 3 GB ZFS pool for postgresql
dd if=/dev/zero of=/var/lib/lxd/disks/pgdata.img bs=100M count=30:
  cmd.run:
    - creates: /var/lib/lxd/disks/pgdata.img

pgdata.img:
  zpool.present:
    - config:
        import: false
        force: true
    - properties:
        comment: Pool for most lxc images
    - layout:
        - /var/lib/lxd/disks/pgdata.img
