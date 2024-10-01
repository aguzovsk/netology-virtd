Vector Role
=========

Use Datadog Vector for dummy log generatation, and use Clickhouse database as sink

Requirements
------------

An Linux instance with (optimal) 512MiB RAM and 1vCPU

Role Variables
--------------

| vars | default | defined in | description |
|------|---------|------------|-------------|
| master_ca_cert_path | N/A | inline or group_vars | Path to CA (Certificate Authority) certificate (selfsigned), so it can be copied and be used with Datadog Vector to connect to Clickhouse |
| clickhouse_hosts | N/A | vars | List of IPs (or resolveable DNS names) which Datadog Vector will use as sinks |
| clickhouse_password | N/A | vars | Password of clickhouse_user, used for authentication in Clickhouse DB |
| clickhouse_user | vector | defaults | User on which behalf we connect to Clickhouse DB (the user should already exist in Clickhouse DB) |
| clickhouse_connection | http | defaults | Either http or https, i.e. protocol to connect to Clickhouse API |
| clickhouse_port | 8123 | defaults | Port to connect to Clickhouse DB |
| clickhouse_db | logs | defaults | Database to use within Clickhouse DB |
| clickhouse_table | datadog | defaults | Table to use in clickhouse_db database within Clickhouse DB |
| vector_version | latest | defaults | Datadog Vector version to download and install |
| vector_user | "{{ ansible_user }}" | defaults | User on which behalf most operations will be performed on the OS |
| save_at | /opt/binaries | defaults | directory where vector binary/archive should be downloaded |


Dependencies
------------

Ansible: none. Will install Datadog's vector agent.

Example Playbook
----------------

    - name: "[Play] Install vector"
      hosts: vector
      vars:
        master_ca_cert_path: "~/clickhouse-tls/clickhouse-01/etc/clickhouse-server/certs/ca_cert.crt"
        clickhouse_password: "s0m3P@ssword"
        clickhouse_hosts:
          - 192.168.61.11
        # override connection settings to Clickhouse DB instances:
        clickhouse_port: 8443
        clickhouse_connection: "https"
      roles:
        - role: vector-role

License
-------

BSD
