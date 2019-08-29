locals {
  app_version = "4.0.9"

  description = <<EOF
Open source, advanced key-value store. It is often referred to as a data
structure server since keys can contain strings, hashes, lists, sets and sorted
sets.
EOF


  engine = "gotpl"
  home   = "http://redis.io/"
  icon   = "https://bitnami.com/assets/stacks/redis/img/redis-stack-220x234.png"

  keywords = [
    "redis",
    "keyvalue",
    "database",
  ]

  maintainers = {
    email = "containers@bitnami.com"
    name  = "bitnami-bot"
  }

  name = "redis"

  sources = [
    "https://github.com/bitnami/bitnami-docker-redis",
  ]

  version = "3.0.5"
}

