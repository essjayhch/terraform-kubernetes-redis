resource "kubernetes_deployment" "redis_metrics" {
  count = var.metrics_enabled ? 1 : 0

  metadata {
    name      = "${local.fullname}-metrics"
    namespace = var.kubernetes_namespace

    labels = {
      app     = local.name
      chart   = local.chart
      release = var.release_name
    }
  }

  spec {
    selector {
      match_labels = {
        app  = local.name
        role = "metrics"
      }
    }

    template {
      metadata {
        labels = {
          app  = local.name
          role = "metrics"
        }

        # TODO: merge pod labels from input variable

        annotations = var.metrics_pod_annotations
      }

      spec {
        dynamic "image_pull_secrets" {
          for_each = var.metrics_image_pull_secrets
          content {
            # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
            # which keys might be set in maps assigned here, so it has
            # produced a comprehensive set here. Consider simplifying
            # this after confirming which keys can be set in practice.

            name = image_pull_secrets.value
          }
        }

        node_selector = var.kubernetes_node_selector

        container {
          name              = "metrics"
          image             = local.metrics_image
          image_pull_policy = var.metrics_image_pull_policy

          env {
            name  = "REDIS_ADDR"
            value = local.metrics_redis_addr
          }

          env {
            name  = "REDIS_ALIAS"
            value = local.fullname
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

          port {
            name           = "metrics"
            container_port = var.metrics_port
          }

          resources {
            dynamic "requests" {
              for_each = [merge(
                local.default_resource_requests,
                var.metrics_resource_requests,
              )]
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
              for_each = [merge(local.default_resource_limits, var.metrics_resource_limits)]
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

