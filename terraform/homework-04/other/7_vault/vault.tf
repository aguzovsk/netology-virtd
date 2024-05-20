data "vault_generic_secret" "vault_example" {
  path = "secret/example"
}

resource "vault_generic_secret" "example_foo" {
  path = "secret/foo"

  data_json = sensitive(<<-EOT
    {
      "foo":   "bar",
      "pizza": "cheese"
    }
    EOT
  )
}

output "foo_example" {
  value = nonsensitive(vault_generic_secret.example_foo.data)
}

output "vault_example" {
  value = nonsensitive(data.vault_generic_secret.vault_example.data)
}


