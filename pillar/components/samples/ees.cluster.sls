cluster:
  cluster_ip:                         # Cluster IP for HAProxy
  pvt_data_nw_addr: 192.168.0.0
  mgmt_vip:                           # Management VIP for CSM
  type: ees                           # single/ees/ecs
  node_list:
    - eosnode-1
    - eosnode-2
  eosnode-1:
    hostname: eosnode-1
    is_primary: true
    network:
      nw_search: pun.seagate.com
      mgmt_nw:                        # Management network interfaces
        iface:
          - eno1
        ipaddr:                       # DHCP is assumed if left blank
        netmask: 255.255.0.0
      data_nw:                        # Data network interfaces
        iface:
          - enp175s0f0                      # Public Data
          - enp175s0f1                      # Private Data (direct connect)
        ipaddr:                       # DHCP is assumed if left blank
        netmask: 255.255.0.0
        roaming_ip:                   # If left blank it is auto-populated by components.system.network.direct
                                      # Applies to private data network
      gateway_ip:                     # Gateway IP of network. Not requried for DHCP.
    storage:
      metadata_device:                # Device for /var/mero and possibly SWAP
        - /dev/sdb                    # Auto-populated by components.system.storage.multipath
      data_devices:                   # Data device/LUN from storage enclosure
        - /dev/sdc                    # Auto-populated by components.system.storage.multipath
  eosnode-2:
    hostname: eosnode-2
    is_primary: false
    network:
      nw_search: pun.seagate.com
      mgmt_nw:                        # Management network interfaces
        iface:
          - eno1
        ipaddr:                       # DHCP is assumed if left blank
        netmask: 255.255.0.0
      data_nw:                        # Data network interfaces
        iface:
          - enp175s0f0                      # Public Data
          - enp175s0f1                      # Private Data (direct connect)
        ipaddr:                       # DHCP is assumed if left blank
        netmask: 255.255.0.0
        roaming_ip:                   # If left blank it is auto-populated by components.system.network.direct
                                      # Applies to private data network
      gateway_ip:                     # Gateway IP of network. Not requried for DHCP.
    storage:
      metadata_device:                # Device for /var/mero and possibly SWAP
        - /dev/sdb                    # Auto-populated by components.system.storage.multipath
      data_devices:                   # Data device/LUN from storage enclosure
        - /dev/sdc                    # Auto-populated by components.system.storage.multipath
  storage_enclosure:
    id: storage_node_1            # equivalent to fqdn for server node
    type: 5U84                    # Type of enclosure. E.g. 5U84/PODS
    controller:
      type: gallium               # Type of controller on storage node. E.g. gallium/indium/sati
      primary_mc:
        ip: 127.0.0.1
        port: 80
      secondary_mc:
        ip: 127.0.0.1
        port: 80
      user: user
      password: 'passwd'

