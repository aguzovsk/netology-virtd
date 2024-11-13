Python version management:
* [Deadsnakes](https://github.com/deadsnakes/docs/blob/main/Ansible.md) (Only Debian-based)
* [tox-uv](https://github.com/tox-dev/tox-uv) (Uses [uv](https://github.com/astral-sh/uv), which is not stable, at the moment) \
  [State](https://astral.sh/blog/uv-unified-python-packaging) at the moment [*](https://www.youtube.com/watch?v=oj8yk0Y-Ky0)
* [tox-pipenv](https://github.com/tox-dev/tox-pipenv) (not updated for long) \
  (Pipenv itself is obsolete)
* pyenv

Let's use `uv` and `tox-uv`, since tool is under development, and will be stable soon.


```bash
docker build -t my-systemd-img .
# -v ./html:/var/www/html:Z 
docker run -d --rm --name rhel-8 -p 8280:80 my-systemd-img
docker exec -it rhel-8 bash
```




tox:
```bash
# lxc launch images:fedora/40/cloud tox-fedora
# lxc config set tox-fedora security.nesting=true
# lxc config set podman-host security.privileged=true
lxc launch -c security.nesting=true -c security.privileged=true images:fedora/40/cloud tox-fedora


lxc config device add tox-fedora ansible disk source=$PWD/08-ansible-04-role/ path=/root/ansible
lxc config device add tox-fedora clickhouse-tls disk source=$HOME/clickhouse-tls/ path=/root/clickhouse-tls


# To run privileged containers inside LXC container:
cat <<EOT | lxc config set tox-fedora raw.lxc -
lxc.cgroup.devices.allow = a
lxc.cap.drop =
EOT

lxc restart tox-fedora
##################################################


lxc shell tox-fedora
```

[Source](https://github.com/astral-sh/uv/issues/4151#issuecomment-2155702400):
```
uv does not include installed tools to PATH automatically, you need to initiate virtual environment first.
```


* `uv pip install` — will install packages as you expect (according to pip fashion, with respect to virtual environments)
* `uv tool install` — will install in `JavaScript`/`Node.js` fashion
  - each tool will install its dependencies in "submodules"
  - virtual environments are not respected

> [!CAUTION]
> Be aware if Ansible is installed on the system level (i.e. with --system specified or not within virtual environment) calling ansible from within virtual environment may meet selinux failure.
> (ansible-config dump -> No executable found at /usr/bin/python${version}, i.e. it will search Python executable at the exact location, ignoring $PATH)

```bash
# Inside tox-fedora
# curl -fsSL https://get.docker.com/ | sh
# systemctl enable --now docker

dnf install -y podman rsync
# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
# source $HOME/.cargo/env
# Install tox with plugin tox-uv (https://github.com/tox-dev/tox-uv?tab=readme-ov-file#how-to-use)

uv venv
source .venv/bin/activate
uv pip install --system --no-cache ansible-core
uv pip install --system --no-cache ansible
uv pip install --system --no-cache molecule molecule_docker molecule_podman
uv pip install --system --no-cache tox tox-uv


uv tool install tox --with tox-uv
uv python install 3.9 3.10 3.11 3.12 3.13
uv tool install --no-cache --link-mode=symlink ansible-core
uv tool install --no-cache ansible
uv tool install --no-cache molecule --with molecule_docker --with molecule_podman
uv tool install --no-cache requests # Is required by molecule test -d docker-based
# /root/.local/share/uv/tools/molecule/lib/python3.12/site-packages
ln -s /usr/lib/python3.12/site-packages/requests /root/.local/share/uv/tools/ansible-core/lib/python3.12/site-packages/
ln -s /usr/lib/python3.12/site-packages/urllib3 /root/.local/share/uv/tools/ansible-core/lib/python3.12/site-packages/
ln -s /usr/lib/python3.12/site-packages/charset_normalizer /root/.local/share/uv/tools/ansible-core/lib/python3.12/site-packages/
```
requirements-dev.txt
```
covdefaults
coverage
pytest
```

```bash
tox -e py313-ansible217 -- generic-podman

tox -e py39 -- tests -k fstring


tox --devenv venv
. venv/bin/activate
pytest tests
```

ansible-lint --force-color --strict

Molecule:
* https://www.youtube.com/watch?v=hglpWHMyFHA

Tox:
* https://www.youtube.com/watch?v=XUMqKoQEls8
* https://github.com/robertdebock/ansible-role-forensics/blob/master/tox.ini

Ansible-Python version matrix:
* [Ansible-Python version matrix](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-core-support-matrix)
* [ansible-community relation to ansible-core](https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html#ansible-community-changelogs)
