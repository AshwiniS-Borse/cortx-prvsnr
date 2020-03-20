{% if pillar['cluster'][grains['id']]['is_primary'] -%}
Setup Cluster:
  pcs.cluster_setup:
    - nodes: {{ pillar['cluster']['node_list'] }}
    - pcsclustername: {{ pillar['corosync-pacemaker']['cluster_name'] }}
    - extra_args:
      - '--start'
      - '--enable'
      - '--force'

Ignore the Quorum Policy:
  pcs.prop_has_value:
    - prop: no-quorum-policy
    - value: ignore

Disable STONITH:
  pcs.prop_has_value:
    - prop: stonith-enabled
    - value: false
{% endif %}
