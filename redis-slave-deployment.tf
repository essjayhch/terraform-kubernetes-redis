resource "kubernetes_deployment" "redis_slave" {
  metadata {
    name      = "${local.fullname}-slave"
    namespace = var.kubernetes_namespace

    labels = {
      app     = local.name
      chart   = local.chart
      release = var.release_name
    }
  }

  spec {
    replicas = var.slave_replica_count

    selector {
      match_labels = {
        app  = local.name
        role = "slave"
      }
    }

    template {
      metadata {
        labels = {
          app  = local.name
          role = "slave"
        }

        # TODO: merge pod labels from input variable

        annotations = var.slave_pod_annotations
      }

      spec {
        node_selector = var.kubernetes_node_selector

        container {
          name              = local.fullname
          image             = local.redis_image
          image_pull_policy = var.redis_image_pull_policy
          args              = coalescelist(var.slave_args, var.master_args)

          env {
            name  = "REDIS_REPLICATION_MODE"
            value = "slave"
          }

          env {
            name  = "REDIS_MASTER_HOST"
            value = "${local.fullname}-master"
          }

          env {
            name  = "REDIS_PORT"
            value = var.slave_port
          }

          env {
            name  = "REDIS_MASTER_PORT_NUMBER"
            value = var.master_port
          }

          env {
            name = "REDIS_PASSWORD"

            value_from {
              secret_key_ref {
                name = local.fullname
                key  = "redis-password"
              }
            }
          }

          env {
            name = "REDIS_MASTER_PASSWORD"

            value_from {
              secret_key_ref {
                name = local.fullname
                key  = "redis-password"
              }
            }
          }

          env {
            name  = "ALLOW_EMPTY_PASSWORD"
            value = var.use_password ? "no" : "yes"
          }

          env {
            name  = "REDIS_DISABLE_COMMANDS"
            value = join(",", var.master_disable_commands)
          }

          env {
            name  = "REDIS_EXTRA_FLAGS"
            value = join(" ", var.master_extra_flags)
          }

          port {
            name           = "redis"
            container_port = var.slave_port
          }

          resources {
            dynamic "requests" {
              for_each = [merge(local.default_resource_requests, var.slave_resource_requests)]
              content {
                # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
                # which keys might be set in maps assigned here, so it has
                # produced a comprehensive set here. Consider simplifying
                # this after confirming which keys can be set in practice.

                cpu    = lookup(requests.value, "cpu", null)
                memory = lookup(requests.value, "memory", null)
              }
            }

            dynamic "limits" {
              for_each = [merge(local.default_resource_limits, var.slave_resource_limits)]
              content {
                # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
                # which keys might be set in maps assigned here, so it has
                # produced a comprehensive set here. Consider simplifying
                # this after confirming which keys can be set in practice.

                cpu    = lookup(limits.value, "cpu", null)
                memory = lookup(limits.value, "memory", null)
              }
            }
          }
        }
      }
    }
  }
}

