```bash
docker pull aragast/netology:latest # -> 2.46 GB
docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive aragast/netology:latest
```

Docker layers:

```bash
docker save aragast/netology:latest -o aragast-image.tar
mkdir aragast-image && tar -xf aragast-image.tar -C aragast-image
mkdir containers
tar -xf aragast-image/blobs/sha256/ad31c78ef2aad651a8167379bfa217d7e97f8e5e742f12947bf703582b9bf5d6 -C containers
mkdir blob-2
sudo tar -xf aragast-image/blobs/sha256/edc910464a340c0bdd1900afac9503a40ce1758920c7cfbb1c5e0df0ae76e93d -C blob-2

tar -tvf aragast-image/blobs/sha256/773711fd02f009e3bc5f9e2b1e859bf2103ba7318b3eb73390490afb3a3a8848
tar xvfO aragast-image/blobs/sha256/773711fd02f009e3bc5f9e2b1e859bf2103ba7318b3eb73390490afb3a3a8848
```

<details>
<summary>Docker Layers</summary>

```Dockerfile
# 3 blobs layers:
#
# 1. OS layer (sha256:5bf135c4a0de07e52c11282c0954e3e6b7c7ddc6c8834a7fd2803c3dc6a31a69)
# 2. (sha256:773711fd02f009e3bc5f9e2b1e859bf2103ba7318b3eb73390490afb3a3a8848)
# 3. (sha256:edc910464a340c0bdd1900afac9503a40ce1758920c7cfbb1c5e0df0ae76e93d)
#   a) nftables (xtables)
#   b) tox
#   c) podman
#       1. runc
#       2. cni
#       3. catatonit
#       4. criu 
# sha256:90f756fdb02505b531412358e4d6b1fd51ea3d45c0fb7ba3a748d4a56f5e6f72 # -> 34 MB
RUN yum reinstall glibc-common -y
# sha256:bf5fdfdece09c7a70911ff2c2d55859d0613826537a225a450290a07adc6d45a # -> 151 MB
RUN yum update -y && yum install tar gcc make python3-pip zlib-devel openssl-devel yum-utils libffi-devel -y
# sha256:bf6e4ea6ac86e5c2ed7394ce3570abe13c79c973fd315028f9d6670cec8090ba # -> 23 MB
ADD https://www.python.org/ftp/python/3.6.13/Python-3.6.13.tgz Python-3.6.13.tgz
# sha256:27b8be3311c0478fd110669f831603666f06956bf71ef448105f3505388ad44e # -> 386 MB
RUN tar xf Python-3.6.13.tgz && cd Python-3.6.13/ && ./configure && make && make altinstall
# sha256:44f2187dc42f116b39da70c78e917ea023b290f27af64bc22204d86e58bae50e # -> 23 MB
ADD https://www.python.org/ftp/python/3.7.10/Python-3.7.10.tgz Python-3.7.10.tgz
# sha256:736521b171bd910005dc77e9f55fbb467879ffa45232c8c56d7f0b7b3dd1e22f # -> 427 MB
RUN tar xf Python-3.7.10.tgz && cd Python-3.7.10/ && ./configure && make && make altinstall
# sha256:37c48476d418440a3ba005b9de8135eb44dbe96ed56869ce9e810432d6b991f5 # -> 24 MB
ADD https://www.python.org/ftp/python/3.8.8/Python-3.8.8.tgz Python-3.8.8.tgz
# sha256:9422d2b0b33c26af64cea562ed58323baef66bc22a193a124ab0845070bf26ee # -> 470 MB
RUN tar xf Python-3.8.8.tgz && cd Python-3.8.8/ && ./configure && make && make altinstall
# sha256:59771d2bba4a264225985bf99bc65bcbc74e779ac45c1f6de3632c4d3b7cf4a9 # -> 25 MB
ADD https://www.python.org/ftp/python/3.9.2/Python-3.9.2.tgz Python-3.9.2.tgz
# sha256:f94575c39351c95573c19ab543b3cc67bce34b1f118a7f43dbd88230eee02163 # -> 503 MB
RUN tar xf Python-3.9.2.tgz && cd Python-3.9.2/ && ./configure && make && make altinstall
# sha256:44a0a43fb59dbc6d38ab6e90a01435ba293312dbe135e8ce3203a13cca104750 # -> 35 M
RUN python3 -m pip install --upgrade pip && pip3 install tox selinux
# sha256:2935e73c804175a9ad980b1fcd45f1db3686f286e853e5e4c63122bdcaaa04e3 # -> 5,0 K
RUN rm -rf Python-*
# sha256:ad31c78ef2aad651a8167379bfa217d7e97f8e5e742f12947bf703582b9bf5d6 # -> 3,0 K
ADD containers.conf /etc/containers/containers.conf
```
</details>


<details>
<summary>/etc/containers/containers.conf</summary>

```
[containers]
netns="host"
userns="host"
ipcns="host"
utsns="private" # <-initially was "host"
cgroupns="host"
cgroups="disabled"
log_driver = "k8s-file"
[engine]
cgroup_manager = "cgroupfs"
events_logger="file"
runtime="crun"
```
</details>

<details>
<summary>/etc/os-release</summary>

```
NAME="Red Hat Enterprise Linux"
VERSION="8.6 (Ootpa)"
ID="rhel"
ID_LIKE="fedora"
VERSION_ID="8.6"
PLATFORM_ID="platform:el8"
PRETTY_NAME="Red Hat Enterprise Linux 8.6 (Ootpa)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:8::baseos"
HOME_URL="https://www.redhat.com/"
DOCUMENTATION_URL="https://access.redhat.com/documentation/red_hat_enterprise_linux/8/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"

REDHAT_BUGZILLA_PRODUCT="Red Hat Enterprise Linux 8"
REDHAT_BUGZILLA_PRODUCT_VERSION=8.6
REDHAT_SUPPORT_PRODUCT="Red Hat Enterprise Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="8.6"
```
</details>

<details>
<summary>Some internals</summary>

```bash
ls --sort=size -lh blob-2/usr/bin/
# total 60M
# -rwxr-xr-x 1 root root  48M apr 19  2022 podman
# -rwxr-xr-x 1 root root  11M apr 19  2022 runc
# -rwxr-xr-x 1 root root 498K apr 19  2022 crun
# -rwxr-xr-x 1 root root 160K nov 30  2021 kmod
# -rwxr-xr-x 1 root root 157K apr 19  2022 conmon
# -rwxr-xr-x 1 root root 108K apr 19  2022 fuse-overlayfs
# -rwxr-xr-x 1 root root  71K apr 19  2022 slirp4netns
# -rwsr-xr-x 1 root root  37K feb 24  2022 fusermount3
# -rwxr-xr-x 1 root root  18K aug 12  2018 json_reformat
# -rwxr-xr-x 1 root root  13K aug 12  2018 json_verify
# -rwxr-xr-x 1 root root  13K dec  9  2021 getsubids
ls --sort=size -lh blob-2/usr/lib/tmpfiles.d/
# -rw-r--r-- 1 root root 338 apr 19  2022 podman.conf
# -rw-r--r-- 1 root root  29 apr 19  2022 criu.conf
cat blob-2/usr/lib/tmpfiles.d/criu.conf
# -> d /run/criu 0755 root root -

ls --sort=size -lh blob-2/usr/libexec/cni/
# total 59M
# -rwxr-xr-x 1 root root 8,7M apr 19  2022 dhcp
# -rwxr-xr-x 1 root root 3,8M apr 19  2022 firewall
# -rwxr-xr-x 1 root root 3,7M apr 19  2022 bridge
# -rwxr-xr-x 1 root root 3,6M apr 19  2022 ptp
# -rwxr-xr-x 1 root root 3,5M apr 19  2022 macvlan
# -rwxr-xr-x 1 root root 3,4M apr 19  2022 ipvlan
# -rwxr-xr-x 1 root root 3,4M apr 19  2022 vlan
# -rwxr-xr-x 1 root root 3,3M apr 19  2022 bandwidth
# -rwxr-xr-x 1 root root 3,3M apr 19  2022 host-device
# -rwxr-xr-x 1 root root 3,3M apr 19  2022 portmap
# -rwxr-xr-x 1 root root 2,9M apr 19  2022 vrf
# -rwxr-xr-x 1 root root 2,9M apr 19  2022 sbr
# -rwxr-xr-x 1 root root 2,9M apr 19  2022 tuning
# -rwxr-xr-x 1 root root 2,8M apr 19  2022 host-local
# -rwxr-xr-x 1 root root 2,8M apr 19  2022 loopback
# -rwxr-xr-x 1 root root 2,4M apr 19  2022 static
# -rwxr-xr-x 1 root root 2,3M apr 19  2022 sample

```
</details>

