```bash
# From 08-ansible-04-role

cd roles/vector-role/
molecule init scenario --driver-name docker rhel9-docker
molecule init scenario --driver-name docker debian-docker

molecule init scenario --driver-name podman rhel9-podman
molecule init scenario --driver-name podman debian-podman
```

Local:
```bash
ls ~/.cache/molecule/
```


Changes to [Dockerfile.j2](https://github.com/AlexeySetevoi/ansible-clickhouse/blob/master/molecule/resources/Dockerfile.j2):
* Alpine (3.20)
  - python -> `python3`
  - added `openrc` ==> Since we are using openrc:
    + there is no need for using container in privileged mode
    + /sbin/init shouldn't be called
  - Error: `WARNING: vector.service is already starting`, [Solution](https://github.com/gliderlabs/docker-alpine/issues/437#issuecomment-667456518)
* OpenSUSE (either leap 15.6 or tumbleweed):
  - python -> `python312` (latest available at the moment)
  - removed python-xml (is included in python312)
  - added `systemd`
* RHEL-based (Fedora 40, CentOS Stream 9)
  - removed yum support (dnf support is suffient), yum is needed for older versions, such as:
    + Cent OS 7— / RHEL 7—
    + Fedora 17—
    + Removed line:
      ```bash
      elif [ $(command -v yum) ]; then sed -i 's/^\(tsflags=*\)/# \1/g' /etc/yum.conf && yum makecache fast && yum upgrade -y && yum makecache fast && yum install -y sudo python3 systemd rsyslog man yum-plugin-ovl bash iproute && sed -i 's/plugins=0/plugins=1/g' /etc/yum.conf && yum clean all; \
      ```
  - removed `python3-devel`, `python*-dnf`
  - added `systemd`, `python*-libdnf*`(`python3-libdnf5` required)
* Debian-based (Debian 12, Ubuntu 24.04)
  - removed apt-transport-https (deprecated, since apt 1.5)
  - gnupg2 -> `gpg`

Obsolete commands:
* molecule init role
* molecule lint


Delegated:
* [Docs](https://ansible.readthedocs.io/projects/molecule/configuration/#delegated)
* [Medium](https://medium.com/@fabio.marinetti81/validate-ansible-roles-through-molecule-delegated-driver-a2ea2ab395b5)
* [Example](https://github.com/ansible/molecule/issues/1292)


Notes:

https://ansible.readthedocs.io/projects/molecule/configuration/#molecule.provisioner.ansible.Ansible

```
The extra hosts added to the inventory using this key won't be created/destroyed by Molecule. It is the developers responsibility to target the proper hosts in the playbook
```

[dependency](https://ansible.readthedocs.io/projects/molecule/configuration/#dependency)
