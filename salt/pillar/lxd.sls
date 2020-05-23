lxd:
  lxd:
    run_init: True
  images:
    local:
      xenial_amd64:
        name: xenial/amd64    # Its alias
        source:
          name: ubuntu/xenial/amd64
          remote: images_linuxcontainers_org    # See map.jinja for it
        public: False
        auto_update: True
  profiles:
    local:
      basics:
        config:
          environment.TZ: "America/Vancouver"
          security.privileged: false
          security.nesting: false
      autostart:
        config:
          # Enable autostart
          boot.autostart: 1
          # Delay between containers in seconds.
          boot.autostart.delay: 2
          # The lesser the later it gets started on autostart.
          boot.autostart.priority: 1
      docker:
        config:
          security.nesting: true
      # TODO most my VMs should be talking to each other.
      # and no access except for bastion.
      # add_eth1:
      #   devices:
      #     eth1:
      #       type: "nic"
      #       nictype": "bridged"
      #       parent": "br1"
      pgdata:
        devices:
          shared_mount:
            type: "disk"
            # Source on the host
            source: "/var/lib/lxd/disks/pgdata.img"
            # Path in the container
            path: "/mnt/pgdata"
  containers:
    local:
      master:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
        config:
          boot.autostart.priority: 1000
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_basics
      postgres:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
          - pgdata
        config:
          boot.autostart.priority: 100
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_pgdata
            - lxd_profile: lxd_profile_local_basics
      redis:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
        config:
          boot.autostart.priority: 100
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_basics
      mail:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
          - docker
        config:
          boot.autostart.priority: 500
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_basics
            - lxd_profile: lxd_profile_local_docker
      keycloak:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
          - docker
        config:
          boot.autostart.priority: 10
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_basics
            - lxd_profile: lxd_profile_local_docker
      web:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
          - docker
        config:
          boot.autostart.priority: 2000
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_basics
            - lxd_profile: lxd_profile_local_docker
      discourse:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
          - docker
        config:
          boot.autostart.priority: 2000
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_basics
            - lxd_profile: lxd_profile_local_docker
      bastion:
        running: True
        source: xenial/amd64
        profiles:
          - default
          - basics
          - autostart
          - docker
        config:
          boot.autostart.priority: 100
        opts:
          require:
            - lxd_profile: lxd_profile_local_autostart
            - lxd_profile: lxd_profile_local_basics
            - lxd_profile: lxd_profile_local_docker
