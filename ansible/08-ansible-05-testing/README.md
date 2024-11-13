# Домашнее задание к занятию 5 «Тестирование roles»

## Deprecations

* molecule init role
* molecule lint
* verifier.playbooks
* [molecule-docker](https://pypi.org/project/molecule-docker/) \
  See: [GitHub](https://github.com/ansible-community/molecule-docker).
  Was archived on `2023-01-05`
* [molecule-podman](https://pypi.org/project/molecule-podman/) \
  See: [GitHub](https://github.com/ansible-community/molecule-podman).
  Was archived on `2023-01-08`

## Molecule

(Tested Ubuntu 24.04)

### General

<details>
<summary>Networks</summary>

* Docker networks:
  + lighthouse role:
    - rhel9-docker: `192.168.62.128/28`
    - generic-docker: `192.168.62.144/28`
  + vector role:
    - rhel9-docker: `192.168.62.160/28`
    - generic-docker: `192.168.62.176/28`
* Podman networks:
  + lighthouse role:
    - rhel9-podman: `192.168.62.192/28`
    - generic-podman: `192.168.62.208/28`
  + vector role:
    - rhel9-podman: `192.168.62.224/28`
    - generic-podman: `192.168.62.240/28`
</details>



<details>
<summary>Dependencies</summary>

Deprecated:
| Dependency | Version |
|------------|---------|
| Molecule Podman | 2.0.3 |
| Molecule Docker | 2.1.0 |

Used:
| Dependency | Version |
|------------|---------|
| Molecule | 24.9.0 |
| Molecule Plugins | 23.5.3 |
| Docker | 27.3.1 |
| Podman | 4.9.3 |
| Tox | 4.21.2 |
| tox-uv | 1.13.0 |
| uv | 0.5.0 |

| Image | Version |
|-------|---------|
| Debian | 12 (bookworm) |
| Ubuntu | 24.04 (noble) |
| Alpine | 3.20 |
| RHEL UBI | 9 |
| CentOS Stream | 9 |
| Fedora | 40 |
| OpenSUSE | Leap 15.6 |
| OpenSUSE | Tumbleweed |

> [!CAUTION]
> Molecule Podman 2.0.3 no network deletion on destroy
</details>

### Code

[Vector-role](https://github.com/aguzovsk/netology-devops/tree/ansible-vector-role/ansible/08-ansible-04-role/roles/vector-role)

[Lighthouse-role](https://github.com/aguzovsk/netology-devops/tree/ansible-lighthouse-role/ansible/08-ansible-04-role/roles/lighthouse-role)

### Logs
* Vector
  - [Docker + RHEL-ubi9](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/vector/rhel9-docker.html)
  - [Docker + different distributions](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/vector/generic-docker.html)
  - [Podman + RHEL-ubi9](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/vector/rhel9-podman.html)
  - [Podman + different distributions](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/vector/generic-podman.html)
  - [Podman Fedora error](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/vector/generic-podman-error.html)
* LighHouse
  - [Docker + RHEL-ubi9](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/ligthouse/rhel9-docker.html)
  - [Docker + different distributions](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/ligthouse/generic-docker.html)
  - [Podman + RHEL-ubi9](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/ligthouse/rhel9-podman.html)
  - [Podman + different distributions](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/ligthouse/generic-podman.html)
  - [Podman Fedora and Alpine error](https://aguzovsk.github.io/netology-devops/ansible/08-ansible-05-testing/logs/ligthouse/generic-podman-error.html)

## Tox

```bash
docker build -t ansible-tox . -f Dockerfile.tox

docker run --rm -it --privileged --cgroupns=host \
  -v $(realpath ../08-ansible-04-role/roles):/opt/roles \
  -v ./tox.toml:/opt/roles/vector-role/tox.toml \
  -v ./tox.toml:/opt/roles/lighthouse-role/tox.toml \
  ansible-tox bash
```

```bash
cd /opt/roles/vector-role
rm -rf .tox/
tox -e py313-ansible217
```

## Miscellaneous

### OCI Registries to consider:

* https://registry.fedoraproject.org/
* https://registry.opensuse.org/cgi-bin/cooverview
* https://registry.suse.com/repositories
* https://quay.io/search

### Docker

Error ansible for creating docker image with systempaths=unconfined:
```
"msg": "Error creating container: 500 Server Error for http+docker://localhost/v1.47/containers/create?name=clickhouse-rhel9-docker: Internal Server Error (\"invalid --security-opt 2: \"systempaths=unconfined\"\")"
```

```yaml
security_opts:
  - apparmor=unconfined
  - seccomp=unconfined
  - label=disable
  - unmask=ALL
```

### Podman:

Running Podman in rootless mode is a [handful](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md#user-actions) of work

Networks
* [Podman networks explained](https://github.com/eriksjolund/podman-networking-docs)
* [Rootful networking](https://github.com/neverpanic/podman-rootful-network)
* [podman-socket-activated-services](https://github.com/PhracturedBlue/podman-socket-activated-services)
* [Nginx example](https://github.com/eriksjolund/podman-nginx-socket-activation)
* [socket-activate-httpd](https://github.com/eriksjolund/socket-activate-httpd)
* [mariadb-podman-socket-activation](https://github.com/eriksjolund/mariadb-podman-socket-activation)

### Cgroups:

Since memory limitations used on containers, cgroup permissions needed.
Use host cgroups or [create](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_monitoring_and_updating_the_kernel/assembly_using-cgroupfs-to-manually-manage-cgroups_managing-monitoring-and-updating-the-kernel) your own
cgroups:
```bash
# Inside container without mapped or created with permissions cgroups
cat /sys/fs/cgroup/cgroup.controllers
cat /sys/fs/cgroup/cgroup.subtree_control

echo +memory > /sys/fs/cgroup/cgroup.subtree_control
# bash: echo: write error: Operation not supported
echo +io > /sys/fs/cgroup/cgroup.subtree_control
# bash: echo: write error: Operation not supported
echo +rdma > /sys/fs/cgroup/cgroup.subtree_control
# bash: echo: write error: Operation not supported
```