sudo apt install -qq -y -o=Dpkg::Use-Pty=0 --no-install-recommends wget
[ -z $(which docker) ] && wget -nv https://get.docker.com/ -O - | sudo sh

# IAM token needed to login to the private registry - cr.yandex, to download web-app image
read -p "Please, provide iam token: " IAM_TOKEN

set -v
docker login --username iam \
    --password ${IAM_TOKEN} cr.yandex
IS_LOGIN_SUCCESSFUL=$?
set +v

sudo usermod -aG docker yc-user

if [ $IS_LOGIN_SUCCESSFUL -eq 0 ]; then
  echo "Setup was correct. Relogin, please."
else
  echo "Cannot login to cr.yandex. Please, try again."
fi
