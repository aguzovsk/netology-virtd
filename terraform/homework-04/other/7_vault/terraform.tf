provider "vault" {
  address         = "http://localhost:8200"
  skip_tls_verify = true
  token           = "education"
}
