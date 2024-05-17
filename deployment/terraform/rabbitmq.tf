// install rabbitmq through helm
resource "helm_release" "rabbitmq" {
  name       = "rabbitmq"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "rabbitmq"
  namespace  = "rabbitmq"
  create_namespace = true

  set_sensitive {
    name  = "auth.username"
    value = "user"
  }

  set_sensitive {
    name  = "auth.password"
    value = "password"
  }
}