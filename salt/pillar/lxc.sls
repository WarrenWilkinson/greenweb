lxc.container_profile:
  standard_bionic:
    template: download
    options:
      dist: ubuntu
      release: bionic
      arch: amd64
    size: 1G
    # Adding these features doesn't work and I haven't had time to enable. -WW
    # backing: zfs
    # zfs_root: root.img

lxc.network_profile:
  standard_net:
    eth0:
      link: lxcbr0
      type: veth
      flags: up
    # Adding these doesn't work and I don't know what they mean anyway -WW
    # gateway: 10.0.3.1
    # bridge: lxcbr0
