# Setup SWAP and /var/motr
{% set node = grains['id'] %}

# Make SWAP
Ensure SWAP partition is unmounted:
  cmd.run:
    - name: swapoff -a && sleep 2

Label first LUN:
  module.run:
    - partition.mklabel:
      - device: {{ pillar['cluster'][node]['storage']['metadata_device'][0] }}
      - label_type: gpt

# Begin LVM config
# Set LVM flag on partition
# Convert metadata partion to LVM
Set LVM flag:
  module.run:
    - partition.toggle:
      - device: {{ pillar['cluster'][node]['storage']['metadata_device'][0] }}
      - partition: 2
      - flag: lvm
    - require:
      - Create LVM partition
# done setting LVM flag

# Creating LVM physical volume using pvcreate
Make pv_metadata:
  lvm.pv_present:
    - name: {{ pillar['cluster'][node]['storage']['metadata_device'][0] }}2
    - require:
      - Set LVM flag
# done creating LVM physical volumes

# Creating LVM Volume Group (vg); vg_name = vg_metadata_{{ node }}
Make vg_metadata_{{ node }}:
  lvm.vg_present:
    - name: vg_metadata_{{ node }}
    - devices: {{ pillar['cluster'][node]['storage']['metadata_device'][0] }}2
    - require:
      - Make pv_metadata
# done creating LVM VG

# Creating LVM's Logical Volumes (LVs; one for swap and one for raw_metadata)
# Creating swap LV (size: 51% of total VG space - it must be larger than raw metadata)
Make lv_main_swap:
  lvm.lv_present:
    - name: lv_main_swap
    - vgname: vg_metadata_{{ node }}
    - extents: 51%VG          # Reference: https://linux.die.net/man/8/lvcreate
    - require:
      - Make vg_metadata_{{ node }}

# Creating raw_metadata LV (per EOS-8858) (size: all remaining VG space; roughly 49% (less 1TB))
Make lv_raw_metadata:
  lvm.lv_present:
    - name: lv_raw_metadata
    - vgname: vg_metadata_{{ node }}
    - extents: 100%FREE        # Reference: https://linux.die.net/man/8/lvcreate
    - require:
      - Make vg_metadata_{{ node }}
# done creating LVM LVs
# end LVM config

# Format SWAP and metadata (but not raw_metadata!)
# need to replace absolute path with proper structure
# Format SWAP
Make SWAP:
  cmd.run:
    - name: sleep 10 && mkswap -f /dev/vg_metadata_{{ node }}/lv_main_swap && sleep 5
    - onlyif: test -e /dev/vg_metadata_{{ node }}/lv_main_swap
    - require:
      - Make lv_main_swap
      - cmd: Ensure SWAP partition is unmounted

# Activate SWAP device
Enable swap:
  mount.swap:
    - name: /dev/vg_metadata_{{ node }}/lv_main_swap
    - persist: True
    - require:
      - cmd: Make SWAP

# Format metadata partion
Make metadata partition:
  module.run:
    - extfs.mkfs:
      - device: {{ pillar['cluster'][node]['storage']['metadata_device'][0] }}1
      - fs_type: ext4
      - label: cortx_metadata
      - require:
        - Create metadata partition

Refresh partition:
  cmd.run:
    - name: blockdev --flushbufs /dev/disk/by-id/dm-name-mpath* || true
  module.run:
    - partition.probe: []

Setup raid for 2 metadata disks:
  raid.present:
    - name: /dev/md0
    - level: 5
    - devices:
      - {{ pillar['cluster'][node]['storage']['metadata_device'][1] }}
      - {{ pillar['cluster'][node]['storage']['metadata_device'][2] }}
    - run: True

# Refresh
{% if (1 < pillar['cluster']['node_list'] | length) and (pillar['cluster'][grains['id']]['is_primary']) -%}
Update partition tables of both nodes:
  cmd.run:
    - name: sleep 10; timeout -k 10 30 partprobe || true; ssh srvnode-2 "timeout -k 10 30 partprobe || true"

Update partition tables of primary node:
  cmd.run:
    - name: timeout -k 10 30 partprobe || true
{% endif %}
