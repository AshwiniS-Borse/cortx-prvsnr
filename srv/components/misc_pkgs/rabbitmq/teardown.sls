{% import_yaml 'components/defaults.yaml' as defaults %}
Remove RabbitMQ packages:
  pkg.purged:
    - name: rabbitmq-server

Remove RabbitMQ prereqs:
  pkg.purged:
    - name: erlang

Remove /var/lib/rabbitmq:
  file.absent:
    - name: /var/lib/rabbitmq
