docker compose up -d
ansible-playbook --vault-password-file password.txt -i playbook/inventory/prod.yml playbook/site.yml
docker compose down