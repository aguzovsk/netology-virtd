git:
```bash
# From 08-ansible-04-role

ansible-galaxy role remove vector-role
ansible-galaxy role remove lighthouse-role

git worktree add roles/vector-role ansible-vector-role
git worktree add roles/lighthouse-role ansible-lighthouse-role

cd roles/lighthouse-role
git mv ansible/08-ansible-04-role/roles/lighthouse-role/* .
git mv ansible/08-ansible-04-role/roles/lighthouse-role/.travis.yml .
# git status
# Check all files ate moved:
# find ansible/
cd ../..

cd roles/vector-role
git mv ansible/08-ansible-04-role/roles/vector-role/* .
git mv ansible/08-ansible-04-role/roles/vector-role/.travis.yml .
# find ansible/
# git status

cd ../..

ansible-galaxy role list
# - clickhouse, 1.13
# - lighthouse-role, (unknown version)
# - vector-role, (unknown version)
```

```bash
# LightHouse Role
git rm .travis.yml
git rm -r tests

find . -maxdepth 1 -not -path ./ansible -not -path . -not -path ./.git \
  -exec git mv {} ansible/08-ansible-04-role/roles/lighthouse-role/ \;


# Vector role
git rm .travis.yml
git rm -r tests

git add .

find . -maxdepth 1 -not -path ./ansible -not -path . -not -path ./.git \
  -exec git mv {} ansible/08-ansible-04-role/roles/vector-role/ \;
```
