Remove public-data-zone:
  cmd.run:
    - name: firewall-cmd --permanent --delete-zone=public-data-zone

Remove private-data-zone:
  cmd.run:
    - name: firewall-cmd --permanent --delete-zone=private-data-zone

Remove management-zone:
  cmd.run:
    - name: firewall-cmd --permanent --delete-zone=management-zone

#TODO: 1. Use salt module to delete zone, if available.
#      2. Reset other rules set in components.system.firewall.config

include:
  - components.system.firewall.stop
