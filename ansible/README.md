# Домашие задания Ansible

## Установка Ansible

**Ubuntu**:
```bash
sudo add-apt-repository -y 'ppa:deadsnakes/ppa'
sudo apt update
sudo apt install python3.12

python3.12 -m venv venv-12
source venv-12/bin/activate

pip install ansible

# ....

deactivate
```
