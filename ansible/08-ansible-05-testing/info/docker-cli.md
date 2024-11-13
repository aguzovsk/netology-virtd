Docker contaienr, get IP address:
* select network with name `lighthouse-docker-molecule-rhel`, then select IP address
  ```bash
  docker inspect $(docker ps --format '{{ .Names }}' | grep clickhouse) \
    --format '{{ $network := index .NetworkSettings.Networks "lighthouse-docker-molecule-rhel" }}{{ $network.IPAddress }}'
  ```
* Same as above, but shorter
  ```bash
  docker inspect $(docker ps --format '{{ .Names }}' | grep clickhouse) \
    --format '{{ (index .NetworkSettings.Networks "lighthouse-docker-molecule-rhel").IPAddress }}'
  ```

* iterate through all the addresses of `clickhouse` docker containers, returns list
  ```bash
  docker inspect $(docker ps --format '{{ .Names }}' | grep clickhouse) \
    --format '{{ range $name, $value := .NetworkSettings.Networks }}{{ $value.IPAddress }}{{ end }}'
  ```

* selects last element among IP addresses
  ```bash
  docker inspect $(docker ps --format '{{ .Names }}' | grep clickhouse) \
    --format '{{ $address := ""}}{{ range $name, $value := .NetworkSettings.Networks }}{{ $address = $value.IPAddress }}{{ end }}{{ $address }}'
  ```
