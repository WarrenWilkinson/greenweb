# -*- coding: utf-8; mode: yaml -*-
# vim: ft=yaml
---

postgresql-client:
  pkg.installed

# This little script allows me to use salt cmd.script, with shell
# /usr/bin/psql-exec, to run postgresql scripts.
/usr/bin/psql-exec:
  file.managed:
    - contents: |
          #!/bin/sh
          shift
          exec psql -f $@
    - user: root
    - group: root
    - mode: 777
